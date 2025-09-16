
## Hello !

This is my project to deploy a highly available cluster of web servers using AWS-based terraforms. Also, a prometheus instance is deployed for the cluster, which starts collecting metrics from all web servers, and a grafana instance, which starts collecting metrics from prometheus. **With the help of scripts and other tricks, the instances are configured to receive new ips, and not hardcoded, which means that after setting up, destroying and rebuilding the infrastructure - everything will work as before**. And the last element - jenkins, is also deployed already configured and ready to go.

### Used software stack:
1. terraform
2. aws
3. prometheus+grafana
4. jenkins
5. docker (uses jenkins in its pipeline)


---

## Привет!

Это мой проект высокодоступного кластера веб-серверов создаваемого при помощи Terrform на основе облачного провайдера Google Cloud Platform(GCP).Создается несколько серверов для тестового окружения(dev) и для конечного пользователя(prod). Сервер для мониторинга с Prometheus+Grafana для отслеживания состояния серверов. Для CI/CD используется отдельный сервер c Jenkins. Использовании специфики IaC достигается идемпотентность, которая позволяет при помощи файлов конфигурации и скриптов, создавать снова и снова инфроструктуру, которая настраивается автоматически и готова к работе, а после изменений, происходит автоматическое тестирование и внедрение изменений в инфроструктуру. Т.е. если даже уничтожить то при помощи моего проекта все создастся заново таким-же как и было до этого
### Используемы программный стек:
1. Terraform
2. GCP
3. Prometheus
4. Grafana
5. Jenkins
6. Docker
7. Nginx

