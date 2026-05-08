# Próximos Passos — APIs de Region e Frontend

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
{ "serial": "9f55bbfd" }
```

Retorna:
```json
{ "output": "<output do pxetools>" }
```

---

## Frontend (site de configuração)

Um site simples foi criado em paralelo no projeto [`iot-tofu-site`](https://github.com/paulovcmonteiro/iot-tofu-site) *(repositório separado)* usando Next.js + Tailwind, hospedável na Vercel.

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
