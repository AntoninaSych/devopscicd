To run:
```chmod u+x install_dev_tools.sh```

```sudo ./install_dev_tools.sh```


To check:

```docker --version
docker compose version   # або docker-compose --version (fallback)
python3 --version
pip3 --version
python3 -c "import django; print(django.get_version())"```
