
## Good day :)!

This is my project of a highly available web server cluster created using Terraform based on the Google Cloud Platform (GCP) cloud provider. Several servers are created for the test environment (dev) and for the end user (prod). Servers are created in different regions and zones in order to increase fault tolerance. A monitoring server with Prometheus + Grafana to track the status of servers. A separate server with Jenkins is used for CI / CD. Using the specifics of IaC, idempotency is achieved, which allows you to create an infrastructure over and over again using configuration files and scripts, which is configured automatically and is ready for work, and after changes, automatic testing and implementation of changes to the infrastructure occurs. That is, even if you destroy it, then with the help of my project everything will be created again the same as it was before.
### The software stack used:
1. Terraform
2. GCP
3. Prometheus
4. Grafana
5. Jenkins
6. Docker
7. Nginx


---

## Добрый день :)!

Это мой проект высокодоступного кластера веб-серверов создаваемого при помощи Terraform на основе облачного провайдера Google Cloud Platform(GCP).Создается несколько серверов для тестового окружения(dev) и для конечного пользователя(prod). Сервера создаются в разных регионах и зонах в целях увеличения отказоустойчивости. Сервер для мониторинга с Prometheus+Grafana для отслеживания состояния серверов. Для CI/CD используется отдельный сервер c Jenkins. Использовании специфики IaC достигается идемпотентность, которая позволяет при помощи файлов конфигурации и скриптов, создавать снова и снова инфроструктуру, которая настраивается автоматически и готова к работе, а после изменений, происходит автоматическое тестирование и внедрение изменений в инфроструктуру. Т.е. если даже уничтожить то при помощи моего проекта все создастся заново таким-же как и было до этого.
### Используемы программный стек:
1. Terraform
2. GCP
3. Prometheus
4. Grafana
5. Jenkins
6. Docker
7. Nginx

