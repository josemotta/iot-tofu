# Próximos Passos — APIs de Region e Frontend

## Instalação Claude

O `Claude` é um assistente de inteligência artificial generativa criado pela empresa Anthropic. Ele funciona baseado em grandes modelos de linguagem (LLMs), processando textos, imagens e códigos de programação para conversar, responder a perguntas e executar tarefas complexas de forma natural.

```bash
sudo curl -fsSLo /usr/share/keyrings/claude-desktop-archive-keyring.asc https://downloads.claude.ai/claude-desktop/key.asc

gpg --show-keys /usr/share/keyrings/claude-desktop-archive-keyring.asc
pub   rsa4096 2026-03-30 [SCE]
      31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE
uid                      Anthropic Claude Code Release Signing <security@anthropic.com>

echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main" | sudo tee /etc/apt/sources.list.d/claude-desktop.list
deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main

sudo apt update && sudo apt install claude-desktop

curl -fsSL https://claude.ai/install.sh | bash

Setting up Claude Code...

✔ Claude Code successfully installed!

  Version: 2.1.227

  Location: ~/.local/bin/claude

```

- Sonnet 5 · Claude Pro
- Tackle your toughest work with Opus 5
- Switch anytime with /model

### Claude saiu mexendo ...

```
Let me verify the final file and that it builds/lints clean.

  Read 1 file, ran 1 shell command

Type check passes. Fixed the command injection in src/controllers/region.controller.ts:

- Switched exec() (which spawns a shell and string-interpolates the command) to execFile(), passing arguments as an array so no shell parses the serial value — shell metacharacters like ; rm -rf / or `...` can no longer break out.
- Added a whitelist regex (^[0-9a-fA-F]{8}$, matching the serial format shown in the README/pxetools examples) and reject anything else with 400 Bad Request before it ever reaches sudo pxetools.
- Also converted the setup() handler's bash ${script} calls to execFile('bash', [script]) for consistency, even though those paths aren't user-controlled.

✻ Brewed for 29s
```

---

## Frontend (site de configuração)

Um site simples foi criado em paralelo no projeto [`iot-tofu-site`](https://github.com/paulovcmonteiro/iot-tofu-site) _(repositório separado)_ usando Next.js + Tailwind, hospedável na Vercel.

O site permite que o usuário final:

1. Clique em **Inicializar Region** → chama `POST /regions/setup`
2. Digite o número de série e clique em **Adicionar RPi** → chama `POST /regions/rpi`

A URL da API é configurada via variável de ambiente `NEXT_PUBLIC_API_URL`.

---

## Próximos passos sugeridos

### 1. Validar os scripts no hardware real

Os endpoints executam os scripts shell diretamente. Antes de usar em produção, testar no Tofu com:

```bash
curl -X POST http://localhost:3000/regions/setup
curl -X POST http://localhost:3000/regions/rpi -H "Content-Type: application/json" -d '{"serial":"9f55bbfd"}'
```

### 2. Tratar erros dos scripts

Atualmente, se um script falhar (exit code != 0), o Node.js lança uma exceção não tratada. Sugestão: capturar o erro e retornar HTTP 500 com a mensagem de erro do shell.

### 3. Adicionar as demais APIs de pxetools

Seguindo o mesmo padrão, as próximas APIs naturais seriam:

- `GET /regions/rpi` → `sudo pxetools --list`
- `DELETE /regions/rpi/:serial` → `sudo pxetools --remove <serial>`
- `POST /regions/reset` → `rpi/pxetools-reset.sh`

### 4. Corrigir `POST /regions/rpi` — comando `--add` é interativo

Ao reverificar `region.controller.ts` contra `rpi/pxetools.py`, dois problemas impedem que o endpoint funcione como está hoje:

- **`pxetools --add` pede input interativo.** Depois de validar o serial, [`add()`](rpi/pxetools.py#L68-L77) chama `input("Owner name: ")`, `input("Pi name: ")` e `input("Enter an option number: ")` (escolha da imagem base em `/nfs/bases`). O endpoint só envia `serial` no body e roda `execFile('sudo', ['pxetools', '--add', serial])` sem stdin conectado — o primeiro `input()` recebe EOF imediato, o Python lança `EOFError` e o processo sai com erro. Ou seja, o endpoint nunca completa um add de verdade, não é só falta de tratamento de erro (item 2 acima) — falta um jeito de repassar `owner`, `name` e a escolha de imagem pro processo filho.
- **O container não tem `sudo` instalado.** `Dockerfile`/`Dockerfile.prod` rodam como usuário não-root `node` e só instalam `git curl bash` via apt — `sudo` nunca é instalado na imagem, e não há sudoers/NOPASSWD configurado em lugar nenhum. `privileged: true` no compose só estende capabilities do container, não instala `sudo` nem dá acesso ao filesystem do host Tofu para mexer em PXE/DHCP/TFTP. Existe `rpi/pipe.sh` (lê comandos de `~/pipe/pipe` e faz `eval`), que parece existir justamente para repassar comandos privilegiados do container pro host via o volume `/hostpipe` montado no compose — mas `region.controller.ts` não usa esse pipe, chama `sudo`/`bash` direto no processo do container. Como está, os dois endpoints devem falhar em produção com `sudo: command not found` em vez de configurar o host.

### 5. Deploy do frontend

- Criar repositório para o `iot-tofu-site`
- Conectar na Vercel
- Setar `NEXT_PUBLIC_API_URL` com o endereço público do Boot-Back

### 6. CORS

Quando o frontend estiver num domínio público chamando a API, será necessário habilitar CORS no Boot-Back. No LoopBack4, isso é feito em `src/application.ts`:

```typescript
this.api({
  openapi: '3.0.0',
  // ...
});
// adicionar middleware de CORS
```

Ou via pacote `@loopback/rest` com a opção `cors` na configuração do RestApplication.

### 6.1 Habilitar CORS em uma API do IBM Loopback

Habilitar o CORS (Compartilhamento de Recursos entre Origens) no LoopBack 4 (a versão atual e mais comum usada em ambientes IBM Cloud/Code Engine) é feito configurando o servidor REST na inicialização da aplicação, pois o CORS já está integrado.Aqui estão as formas de habilitar:1. Habilitar CORS com configurações padrão (Recomendado)Para permitir que qualquer domínio acesse sua API com as configurações de segurança padrão, edite o arquivo src/application.ts ou onde o RestApplication é iniciado.

```typescript
// src/application.ts

import {BootMixin} from '@loopback/boot';
import {ApplicationConfig} from '@loopback/core';
import {RepositoryMixin} from '@loopback/repository';
import {RestApplication} from '@loopback/rest';

export class MyApplication extends BootMixin(RepositoryMixin(RestApplication)) {
  constructor(options: ApplicationConfig = {}) {
    super(options);

    // Habilitar CORS com configurações padrão
    this.restServer.configureCors({
      origin: '*', // Permite todas as origens (ajuste para produção)
      methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
      credentials: true,
    });
  }
}
```

### 6.2. Habilitar via index.ts (Configuração Customizada)

Alternativamente, você pode definir as configurações de CORS na função main no arquivo src/index.ts:

```typescript
// src/index.ts

export async function main(options: ApplicationConfig = {}) {
  const config = {
    rest: {
      port: +(process.env.PORT ?? 3000),
      host: process.env.HOST ?? 'localhost',
      // Configuração de CORS
      cors: {
        origin: 'http://meu-frontend.com', // Origem específica
        methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
        preflightContinue: false,
        optionsSuccessStatus: 204,
        credentials: true,
      },
    },
  };
  const app = new MyApplication(config);
  // ... resto do código
}
```

### 6.3. Habilitar CORS em Ambientes IBM Cloud (Code Engine/API Connect)

Se sua aplicação está rodando em contêineres, certifique-se de que o CORS está habilitado no código Node.js/Express, conforme mostrado acima, pois o IBM Code Engine é baseado em Express.Se estiver usando o IBM API Connect, você pode ativar o CORS diretamente na guia Gateway da definição da API, selecionando Ativar CORS.

### 6.4 Como verificar se funcionou

Após reiniciar a API, o navegador deve receber o cabeçalho Access-Control-Allow-Origin: \* (ou o domínio que você definiu) nas respostas.
