# Precificação VetClin

Calculadora de precificação da clínica e farmácia veterinária VetClin. É um único arquivo, `index.html`: abra no navegador, sem instalar nada. Os valores editados ficam salvos no próprio navegador (localStorage).

## Abas

- **Procedimentos**: consultas, exames rápidos, vacinas, microchipagem e cirurgias. Soma a hora-clínica ou a hora-centro cirúrgico, os insumos, o protocolo anestésico (escalado pela faixa de peso), os impostos, a taxa do cartão e a margem.
- **Farmácia & Balcão**: preço por margem de contribuição sobre o CMV (custo da NF + frete/ST + perdas), com a lista de produtos por segmento.
- **Tabela de serviços**: todos os procedimentos de uma vez, com preço mínimo, preço sugerido e status da margem.
- **Parâmetros de custo**: custos fixos, rateio, Simples Nacional, comissões, taxas da maquininha de 1x a 12x, metas, faixas de peso e protocolos anestésicos.

## Fórmulas

- Hora-clínica = custos fixos × parcela do consultório ÷ horas clínicas/mês
- Hora-centro cirúrgico = (custos fixos × parcela do CC + depreciação do CC) ÷ horas de CC/mês
- Preço sugerido = custo direto ÷ (1 − imposto − taxa do cartão − comissão − rateio fixo % − margem)
- Ponto de equilíbrio = custo direto ÷ (1 − imposto − taxa do cartão − comissão − rateio fixo %)
- Lucro líquido real = preço × (1 − imposto − taxa − comissão − rateio fixo %) − custo direto
- Alerta: margem real abaixo da meta = subprecificado; lucro negativo = prejuízo

Todos os números que vêm preenchidos são exemplos e devem ser substituídos pelos da VetClin.

## App Android (APK)

O APK pronto fica em [`dist/VetClin-Precificacao.apk`](dist/VetClin-Precificacao.apk). Ele funciona sem internet: a calculadora e as fontes vão dentro do app, e os dados ficam salvos no celular.

**Instalar:** baixe o APK no celular, abra o arquivo e autorize "instalar apps desconhecidos" para o navegador ou gerenciador de arquivos quando o Android pedir. Requer Android 7.0 ou mais recente.

**Backup:** em Parâmetros de custo → Backup dos dados, toque em "Gerar backup e copiar" e guarde o texto. Para restaurar, cole o texto e toque em "Restaurar do texto abaixo".

**Gerar uma nova versão** depois de alterar o `index.html` (Linux, com Java 17+, Python 3 e Gradle):

```bash
KS_PASS='senha-do-keystore' KEYSTORE=/caminho/vetclin-release.p12 VERSION_CODE=2 VERSION_NAME=1.1 android/build-apk.sh
```

Use sempre o mesmo keystore e aumente o `VERSION_CODE`. Assim o Android instala a atualização por cima, sem apagar os dados. O keystore não fica no repositório, que é público.
