# VetClin · Preço de Venda

Sistema de precificação da clínica veterinária VetClin, baseado no curso **"Como definir o preço de venda" do Sebrae**. Já vem com os custos de outubro/2026 e o faturamento da planilha `Custo_Clinica_10_26.xlsx`.

## Downloads

| Plataforma | Arquivo | Como instalar |
|---|---|---|
| Windows 10/11 | [`dist/VetClin-Preco-de-Venda.exe`](dist/VetClin-Preco-de-Venda.exe) | Baixe e abra. Não precisa instalar. Se o Windows mostrar "O Windows protegeu o computador", clique em **Mais informações → Executar assim mesmo**. |
| Android 7+ | [`dist/VetClin-Preco-de-Venda.apk`](dist/VetClin-Preco-de-Venda.apk) | Baixe no celular, abra o arquivo e autorize "instalar apps desconhecidos". |
| Navegador | [`index.html`](index.html) | Abra o arquivo em qualquer navegador. |

Tudo funciona sem internet. No Windows os dados ficam em `%APPDATA%\VetClin Preco de Venda\dados.json`; no Android e no navegador ficam no próprio aparelho. Para passar os dados de um aparelho para outro, use **Custos da clínica → Backup dos dados**.

## Seções

- **Produtos**: preço sugerido de cada produto da farmácia, a partir do custo da nota fiscal. Mostra o preço mínimo (lucro zero), o markup e se o preço praticado hoje dá lucro.
- **Serviços**: consultas, exames, cirurgias e internações. O preço considera o tempo da equipe, os materiais e os serviços de terceiros.
- **Notas de entrada**: lançamento das notas fiscais de compra. Frete, ST/IPI e desconto são rateados entre os itens, e o item pode ser fracionado (ex.: caixa com 10 blisters vendidos soltos). No Windows e no navegador também dá para importar o XML da NF-e.
- **Custos da clínica**: custos do mês (pode colar do Excel), parâmetros (impostos, cartão, divisão dos custos fixos) e indicadores: peso dos custos fixos, ponto de equilíbrio e margem de segurança.

A margem de lucro é editável por seção (padrão: 15% em produtos e 20% em serviços) e também por item.

## Fórmulas (Sebrae)

- **Produtos (comércio)**: Preço = Custo total ÷ (1 − (custos fixos % + impostos % + cartão % + lucro %))
  - Custo total = custo unitário da NF (com frete e despesas rateados) × (1 + perdas %)
  - Custos fixos % = custos fixos atribuídos aos produtos ÷ faturamento de produtos
- **Serviços**: Preço = Custo total ÷ (1 − (lucro % + impostos % + cartão %))
  - Custo total = materiais + terceiros + minutos × custo do minuto
  - Custo do minuto = custos fixos atribuídos aos serviços ÷ minutos atendidos no mês (tempo × quantidade de cada serviço)
- **Margem de contribuição** = preço − custos variáveis. **Ponto de equilíbrio** = custos fixos ÷ margem de contribuição %.

Compras de mercadoria **não** entram nos custos fixos: o custo delas chega pelo preço de compra de cada produto. Empréstimos e pró-labore entram como custo fixo.

## Gerar novas versões

Depois de alterar o `index.html`:

```bash
windows/build-exe.sh                                   # precisa de Go e Python com Pillow
KS_PASS='senha' KEYSTORE=/caminho/vetclin-release.p12 VERSION_CODE=2 VERSION_NAME=2.1 android/build-apk.sh
```

No Android, use sempre o mesmo keystore e aumente o `VERSION_CODE`. Assim a atualização instala por cima sem apagar os dados. O keystore não fica no repositório.
