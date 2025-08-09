# Infraestrutura como Código: Servidor Web na AWS com Terraform

![Terraform](https://img.shields.io/badge/Terraform-%237B42BC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)

## 📄 Descrição do Projeto

Este repositório contém um projeto de **Infraestrutura como Código (IaC)** que provisiona de forma totalmente automatizada um servidor web Nginx na AWS. O objetivo é demonstrar habilidades em automação de nuvem, gerenciamento de redes e boas práticas de IaC com Terraform.

Ao executar este código, uma infraestrutura de nuvem completa e isolada é criada, incluindo rede, firewall e uma máquina virtual que se autoconfigura ao ser iniciada.

---

## 🏛️ Arquitetura da Infraestrutura

A infraestrutura criada pelo Terraform é composta pelos seguintes recursos:

* **VPC (Virtual Private Cloud):** Uma rede virtual privada e isolada para garantir a segurança.
* **Subnet Pública:** Uma sub-rede dentro da VPC com acesso à internet.
* **Internet Gateway:** Permite a comunicação entre a VPC e a internet.
* **Tabela de Rotas:** Direciona o tráfego da subnet para o Internet Gateway.
* **Security Group:** Atua como um firewall virtual, liberando apenas o tráfego necessário (HTTP na porta 80 e SSH na porta 22).
* **Instância EC2:** Uma máquina virtual (usando `t3.micro` do Free Tier) onde o servidor web Nginx é instalado e executado automaticamente via `user_data`.
* **AMI Dinâmica:** O código utiliza um `data source` para buscar dinamicamente a AMI (Imagem de Máquina da Amazon) mais recente do Amazon Linux 2023, garantindo que o servidor seja sempre criado com a imagem mais atual.
  
---

## 🛠️ Tecnologias Utilizadas

* **Terraform (v1.8+):** Ferramenta principal para definir e provisionar a infraestrutura como código.
* **AWS (Amazon Web Services):** Provedor de nuvem onde a infraestrutura é hospedada.
    * **EC2:** Para a máquina virtual.
    * **VPC, Subnets, Route Tables, Internet Gateway:** Para a configuração da rede.
    * **Security Groups:** Para o firewall.
* **Nginx:** Servidor web instalado na instância EC2.

---

## 🚀 Como Executar o Projeto

Para replicar esta infraestrutura na sua própria conta AWS, siga os passos abaixo.

### Pré-requisitos

Antes de começar, garanta que você tenha:
1.  Uma **conta na AWS**.
2.  O **Terraform** (versão 1.8 ou superior) instalado na sua máquina.
3.  O **AWS CLI** instalado e configurado com suas credenciais (`aws configure`).

### Passo a Passo

1.  **Clone este repositório:**
    ```bash
    git clone https://github.com/SchiavonNathan/terraform-aws-nginx-server.git
    cd terraform-aws-nginx-server
    ```

2.  **Inicialize o Terraform:**
    Este comando inicializa o diretório de trabalho, baixando os plugins necessários para o provedor AWS.
    ```bash
    terraform init
    ```

3.  **Planeje a Execução (Opcional, mas recomendado):**
    Este comando cria um plano de execução e mostra quais recursos serão criados, alterados ou destruídos. É uma ótima forma de revisar as mudanças antes de aplicá-las.
    ```bash
    terraform plan
    ```

4.  **Aplique a Configuração:**
    Este comando executa as ações planejadas e constrói a infraestrutura na sua conta AWS. Ele pedirá uma confirmação final. Digite `yes` para continuar.
    ```bash
    terraform apply
    ```

### Resultados Esperados

Ao final da execução do `terraform apply`, o **IP público** da instância EC2 será exibido no seu terminal como um `output`. Copie e cole este IP no seu navegador para ver a página de boas-vindas do Nginx.

```
Outputs:

public_ip = "54.123.45.67"
```

### Destruindo a Infraestrutura

Para evitar custos desnecessários, **lembre-se de destruir todos os recursos** quando terminar de usar o projeto. Este comando irá remover tudo o que foi criado pelo Terraform.

```bash
terraform destroy
```
