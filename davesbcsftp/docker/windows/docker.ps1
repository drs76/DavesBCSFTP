cd C:\Users\Administrator\Documents\projects\al\DavesBCSFTP\azure
docker build -t azfuncs .
docker run -d -p 7071:80 --name azfuncapps azfuncs