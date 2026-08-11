# Próximos Passos — APIs de Region e Frontend

## Instalação Claude

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

```

- Sonnet 5 · Claude Pro
- Tackle your toughest work with Opus 5
- Switch anytime with /model

## O que foi feito neste PR

Dois endpoints foram adicionados ao Boot-Back para incorporar os comandos `pxetools` que antes precisavam ser executados manualmente (conforme mencionado no README).

### `POST /regions/setup`

Executa em sequência:

1. `rpi/pxetools-install.sh` — instala os serviços no servidor de boot
2. `rpi/pxetools-setup.sh` — faz a configuração inicial

Retorna:

```json
{
  "install": "<output do script de instalação>",
  "setup": "<output do script de setup>"
}
```

### `POST /regions/rpi`

Executa `sudo pxetools --add <serial>` com o número de série recebido no body.

Body esperado:

```json
{"serial": "9f55bbfd"}
```

Retorna:

```json
{"output": "<output do pxetools>"}
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

### 4. Deploy do frontend

- Criar repositório para o `iot-tofu-site`
- Conectar na Vercel
- Setar `NEXT_PUBLIC_API_URL` com o endereço público do Boot-Back

### 5. CORS

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
