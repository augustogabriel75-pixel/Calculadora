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
