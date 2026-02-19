# openvas-docker-install-full
Script to install docker in any Linux Based machine

# ============================================================
# MODO DE USO:
- Baixe o arquivo .sh (ou copie seu conteúdo)
- Dê permissão de execução (chmod +x openvas-docker-install-full.sh)
- Execute (./openvas-docker-install-full.sh)
  OBS: não precisa ser root para executar, mas ao longo do processo será solicitado

# ============================================================
# Script interativo para instalação do Greenbone Community Containers via Docker
# Alinhado à documentação oficial Greenbone
# Não é necessário executar com privilégios, o script irá pedir sudo onde necessário.
# Testado em Debian / Ubuntu / Fedora / CentOS / WSL Ubuntu (todas as versões).
# Autor: Matheus Henrique Ferreira Bariani e Perplexity AI
# ============================================================

# O QUE O SCRIPT FAZ:
Passo 1: Verifica se o SO está atualizado
Passo 2: Seleção de distribuição Linux
Passo 3: Instalação do Docker por SO
Passo 4: Criar diretório de download
Passo 5: Baixar docker-compose.yml
Passo 6: Pull das imagens
Passo 7: Up dos containers COM VERBOSE PROGRESSO
- Essa etapa tem um timeout de 900 segundos
Passo 8: Log em tempo real
Passo 9: Alterar senha admin
Passo 10: Abrir interface gráfica
- Possível apenas se estiver em ambiente gráfico
- Não funciona para WSL ou SO apenas em CLI
Passo 11: Info final
# ============================================================

# CASO DÊ ERRO:
# Se alguma etapa falhar ou acusar algum erro basta apenas
# encerrar o processo (Ctrl+C ou Ctrl+Z) e iniciar novamente

ENGLISH VERSION
openvas-docker-install-full
Docker installation script for any Linux machine

# ============================================================
USAGE
Download the .sh file or copy its contents.
Make it executable: chmod +x openvas-docker-install-full.sh
Run it: ./openvas-docker-install-full.sh
Note: No root access needed upfront; the script prompts for sudo as required.

# =============================================================
SCRIPT OVERVIEW  
Interactive installer for Greenbone Community Containers using Docker.
Follows official Greenbone documentation.
Runs without root; requests sudo only when needed.
Tested on: Debian, Ubuntu, Fedora, CentOS, WSL Ubuntu (all versions).
Author: Matheus Henrique Ferreira Bariani & Perplexity AI
# ============================================================

WHAT THE SCRIPT DOES
Checks OS updates – Ensures your system is current.
Detects Linux distro – Auto-selects based on your environment.
Installs Docker – Distro-specific setup.
Creates download dir – Prepares workspace.
Downloads docker-compose.yml – Fetches official config.
Pulls images – Downloads all required containers.
Starts containers – With verbose progress output (900s timeout).
Shows real-time logs – Monitors startup live.
Changes admin password – Secure your setup.
Opens web UI – Launches browser (graphical env only; skips on WSL/CLI).
Displays final info – Access details and next steps.
# ============================================================

TROUBLESHOOTING ERRORS
If a step fails:
- Stop with Ctrl+C or Ctrl+Z.
- Rerun the script – it rerun safely from start but skipping some already done steps.
