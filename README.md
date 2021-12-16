# API_REST
Api de arquivos REST

Métodos implementados

[GET] /api/server - retorna lista de servidores
[POST] /api/server - insere novo servidor. Exemplo de JSON enviado : {"name": "Servidor 01","ip": "127.0.0.1","port": 80}

[GET] /api/server/ID_SERVER - retorna servidor por id.
exemplo de request: http://localhost:8080/api/server/F8390DD4-DD20-4EA5-9573-F74869637404

[PUT] /api/server/ID_SERVER - atualiza por server id.
Exemplo de JSON enviado : {"name": "Servidor 01","ip": "127.0.0.10","port": 80}
exemplo de request: http://localhost:8080/api/server/F8390DD4-DD20-4EA5-9573-F74869637404

[DELETE] /api/server/ID_SERVER - delete por server id.
exemplo de request: http://localhost:8080/api/server/F8390DD4-DD20-4EA5-9573-F74869637404

[GET] /api/server/available/ID_SERVER - verifica disponibilidade do servidor.
exemplo de request: http://localhost:8080/api/server/available/90C596C8-C92D-4EFD-8CB8-085FF3FEDE89
