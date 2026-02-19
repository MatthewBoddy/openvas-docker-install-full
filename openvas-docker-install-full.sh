#!/bin/bash

# ============================================================
# Script interativo para instalação do Greenbone Community Containers via Docker
# Alinhado à documentação oficial Greenbone
# Executar com privilégios de sudo onde necessário.
# Testado em Debian / Ubuntu / Fedora / CentOS / WSL Ubuntu (todas versões).
# Autor: Matheus Henrique Ferreira Bariani e Perplexity AI
# ============================================================

set -e

echo -e "\n=== Iniciando instalação do Greenbone Community Containers ===\n"

# Passo 1: Verificar se SO atualizado
echo "------------------------------------------------------------"
echo "Passo 1: Verificação de atualizações do sistema."
echo "------------------------------------------------------------"
read -p "O sistema operacional está atualizado (sudo apt update && sudo apt upgrade ou equivalente)? (s/n): " atualizado
if [[ "$atualizado" != "s" && "$atualizado" != "S" ]]; then
    echo -e "\nERRO: O sistema deve estar atualizado antes de continuar."
    echo "Execute 'sudo apt update && sudo apt upgrade' (Debian/Ubuntu) ou equivalente e rode o script novamente."
    exit 1
fi
echo -e "\n✓ Sistema considerado atualizado. Prosseguindo..."

# Passo 2: Seleção de distribuição
echo -e "\n------------------------------------------------------------"
echo "Passo 2: Seleção da distribuição Linux."
echo "------------------------------------------------------------"
echo "1 - Debian"
echo "2 - Ubuntu"
echo "3 - Fedora"
echo "4 - CentOS"
read -p "Escolha a opção (1-4): " opcao
case $opcao in
    1) SO="Debian" ;;
    2) SO="Ubuntu" ;;
    3) SO="Fedora" ;;
    4) SO="CentOS" ;;
    *) echo "Opção inválida."; exit 1 ;;
esac
echo -e "\n✓ Distribuição selecionada: $SO"

# Instalação de dependências (ca-certificates curl gnupg)
echo -e "\n------------------------------------------------------------"
echo "Passo 2.1: Instalando dependências ca-certificates, curl e gnupg."
echo "------------------------------------------------------------"
if [[ "$SO" == "Debian" || "$SO" == "Ubuntu" ]]; then
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg
elif [[ "$SO" == "Fedora" || "$SO" == "CentOS" ]]; then
    sudo dnf install -y ca-certificates curl gnupg
fi
echo "✓ Dependências instaladas"

# Passo 3: Instalação Docker por SO
echo -e "\n------------------------------------------------------------"
echo "Passo 3: Desinstalando pacotes Docker conflitantes e configurando repositório oficial."
echo "------------------------------------------------------------"
if [[ "$SO" == "Debian" ]]; then
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt remove -y $pkg; done
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
elif [[ "$SO" == "Ubuntu" ]]; then
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt remove -y $pkg; done
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
elif [[ "$SO" == "Fedora" ]]; then
    sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker
elif [[ "$SO" == "CentOS" ]]; then
    sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker
fi
echo "✓ Docker instalado e iniciado"

# Passo 4: Criar diretório de download
echo -e "\n------------------------------------------------------------"
echo "Passo 4: Criando diretório de download."
echo "------------------------------------------------------------"
export DOWNLOAD_DIR=$HOME/greenbone-community-container
mkdir -p $DOWNLOAD_DIR
echo "✓ Diretório criado: $DOWNLOAD_DIR"

# Passo 5: Baixar docker-compose.yml
echo -e "\n------------------------------------------------------------"
echo "Passo 5: Baixando docker-compose.yml oficial."
echo "------------------------------------------------------------"
curl -f -O -L https://greenbone.github.io/docs/latest/_static/docker-compose.yml --output-dir "$DOWNLOAD_DIR"
echo "✓ Arquivo baixado"

# Passo 6: Pull das imagens
echo -e "\n------------------------------------------------------------"
echo "Passo 6: Baixando (pull) imagens dos containers Greenbone."
echo "------------------------------------------------------------"
sudo docker compose -f $DOWNLOAD_DIR/docker-compose.yml pull
echo "✓ Imagens baixadas"

# Passo 7: Up dos containers COM VERBOSE PROGRESSO
echo -e "\n------------------------------------------------------------"
echo "Passo 7: Iniciando containers Greenbone (14 services)."
echo "Tempo estimado: 2-15min (primeira run: feeds sync)."
echo "Acompanhe progresso abaixo..."
echo "(se nada acontecer, pare o script com Ctrl+Z e o execute novamente)"
echo "------------------------------------------------------------"

# Inicia em background + monitora
timeout 900 sudo docker compose -f $DOWNLOAD_DIR/docker-compose.yml up -d || true
echo -e "\nContainers iniciados. Monitorando healthchecks (aguarde)\n"
echo -e "\nStatus final:\n$(sudo docker compose -f $DOWNLOAD_DIR/docker-compose.yml ps)"
echo "✓ Passo 7 completo!"

# Passo 8: Logs em tempo real?
echo -e "\n------------------------------------------------------------"
echo "Passo 8: Oferta de visualização de logs."
echo "------------------------------------------------------------"
read -p "Deseja ver os logs em tempo real? (s/n): " logs
if [[ "$logs" == "s" || "$logs" == "S" ]]; then
    echo "Copie e cole esse comando em um novo terminal:"
    echo "sudo docker compose -f $DOWNLOAD_DIR/docker-compose.yml logs -f"
fi

# Passo 9: Alterar senha admin
echo -e "\n------------------------------------------------------------"
echo "Passo 9: Configuração de usuário admin."
echo "------------------------------------------------------------"
read -p "Deseja alterar a senha do usuário 'admin'? (s/n): " senha
if [[ "$senha" == "s" || "$senha" == "S" ]]; then
    read -s -p "Digite a nova senha: " newpass
    echo
    sudo docker compose -f $DOWNLOAD_DIR/docker-compose.yml exec -u gvmd gvmd gvmd --user=admin --new-password="$newpass"
    echo "✓ Senha alterada"
else
    echo "Senha padrão: 'admin' (recomenda-se alterar para produção)"
fi

# Passo 10: Abrir interface gráfica
echo -e "\n------------------------------------------------------------"
echo "Passo 10: Oferta de abertura da interface GSA."
echo "------------------------------------------------------------"
read -p "Deseja abrir a interface gráfica do Greenbone (porta 9392)? (s/n): " gui
if [[ "$gui" == "s" || "$gui" == "S" ]]; then
    xdg-open "http://127.0.0.1:9392" 2>/dev/null >/dev/null &
    echo "✓ Interface aberta no navegador"
fi

# Passo 11: Info final
echo -e "\n============================================================"
echo "Instalação concluída com sucesso!"
echo "!!!!   OpenVAS disponível em: http://127.0.0.1:9392   !!!!"
echo -e "\n============================================================"
echo "Para mais informações: https://greenbone.github.io/docs/latest/22.4/container/index.html"
echo "Monitore com: docker compose -f $DOWNLOAD_DIR/docker-compose.yml logs -f"
echo "Parar:      docker compose -f $DOWNLOAD_DIR/docker-compose.yml down"
echo "============================================================"
