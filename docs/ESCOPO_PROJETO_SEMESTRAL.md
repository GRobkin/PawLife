# PawLife — Escopo do projeto semestral

Projeto individual. Aplicativo móvel (Flutter) para tutores de animais de estimação, com API própria (PHP) e Firebase.

## Proposta
PawLife reúne em um só app o dia a dia do animal: perfil e saúde (vacinas, medicamentos, alimentação, peso, consultas ao veterinário), lembretes e tarefas, e **passeios com rota no mapa** que podem ser compartilhados como imagem.

Público: tutores de cães e gatos, incluindo pessoas com baixa visão ou que preferem tema escuro.

## Requisitos da disciplina e como o app os cobre

| Requisito | O que o app faz | Estado |
|---|---|---|
| **Interface e acessibilidade (Unid. I)** | Formulários com validação (cadastro de animal, vacinas, peso, tarefas). Idiomas es/en/pt, tema claro/escuro/sistema, contraste revisado, respeito a "reduzir movimento", layouts responsivos com testes. | Implementado; falta revisão com leitor de tela em dispositivo |
| **Hardware / localização (Unid. I)** | GPS e mapa (OpenStreetMap) para gravar o passeio: distância, tempo, trajeto. Câmera/galeria para a foto do animal. | Implementado; falta teste em dispositivo físico |
| **Notificações (Unid. I)** | Lembretes de vacinas e tarefas por push (Firebase Cloud Messaging), com atalho direto à tela correspondente; preferências de notificação pelo usuário. | Implementado; falta teste de recebimento real |
| **Desempenho e background (Unid. II)** | Chamadas assíncronas à API com paginação; envio de lembretes por tarefa agendada no servidor (Cloudflare Worker, a cada 5 min). Previsto: manter a gravação do passeio com a tela bloqueada (serviço em primeiro plano no Android). | Parcial; o serviço em segundo plano é o ponto a implementar e testar |
| **Publicação e mercado (Unid. IV)** | Tela "Privacidade e meus dados" (exportar e excluir conta). Política de Privacidade (LGPD) a redigir e publicar. Monetização: assinatura **Premium** (mais animais e tarefas, histórico completo de passeios, estilos de cartão, modo relógio). Anúncios descartados para não poluir a interface. | Premium com compra simulada; política e loja pendentes |

## Wearable (teórico e simulado)
Simulação de relógio circular 250×250 px, fundo preto, um botão principal (iniciar / pausar / terminar o passeio), sem entrada de texto. Código isolado em `lib/views/wearable/`.

## Fora do escopo
Pagamentos reais, rede social entre tutores (planejada em `docs/PLAN_SOCIAL_PASEOS.md`), hardware real de relógio.

## Riscos
- Nada foi testado ainda em dispositivo físico (GPS, câmera, push).
- O identificador do app (`com.example…`) deve ser trocado antes de publicar.
- Mapas dependem das regras de uso do OpenStreetMap (identificação do app e atribuição).
