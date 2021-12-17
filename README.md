# API_REST
Api de arquivos REST

Métodos implementados

[SERVER]

[POST] /api/server - insere novo servidor.
Exemplo de JSON enviado : {"name": "Servidor 01","ip": "127.0.0.1","port": 80}
exemplo de request: http://localhost:8080/api/server

[PUT] /api/server/ID_SERVER - atualiza por server id.
Exemplo de JSON enviado : {"name": "Servidor 01","ip": "127.0.0.10","port": 80}
exemplo de request: http://localhost:8080/api/server/F8390DD4-DD20-4EA5-9573-F74869637404

[DELETE] /api/server/ID_SERVER - delete por server id.
exemplo de request: http://localhost:8080/api/server/F8390DD4-DD20-4EA5-9573-F74869637404

[GET] /api/server/ID_SERVER - recuperar servidor por id.
exemplo de request: http://localhost:8080/api/server/F8390DD4-DD20-4EA5-9573-F74869637404

[GET] /api/server/available/ID_SERVER - verifica disponibilidade do servidor.
exemplo de request: http://localhost:8080/api/server/available/90C596C8-C92D-4EFD-8CB8-085FF3FEDE89

[GET] /api/server - retorna lista de servidores
exemplo de request: http://localhost:8080/api/server

[ARQUIVOS]

[POST] /api/server/[ID_SERVER]/videos - insere novo video no server
Exemplo de JSON enviado :  {"descricao":"12186290.mp4","base64":"INSERIR_CONTEUDO_BINARIO_DO_ARQUIVO","size":3002708}
exemplo de request: http://localhost:8080/api/server/04FEFFB2-BEBA-4D73-BBE6-A68E02F63BB8/videos

[DELETE] /api/server/[ID_SERVER]/videos/ID_VIDEO - deleta arquivo
exemplo de request: http://localhost:8080/api/server/04FEFFB2-BEBA-4D73-BBE6-A68E02F63BB8/videos/B8B8EFCB-5870-4F9F-B90C-D6A30163D2DE

[GET] /api/server/[ID_SERVER]/videos/ID_VIDEO - recupeda dados básicos do arquivo
exemplo de request: http://localhost:8080/api/server/04FEFFB2-BEBA-4D73-BBE6-A68E02F63BB8/videos/B8B8EFCB-5870-4F9F-B90C-D6A30163D2DE

[GET] /api/server/[ID_SERVER]/videos/ID_VIDEO/bin - recupeda dados binarios do arquivo
exemplo de request: http://localhost:8080/api/server/0B824499-E3A4-4C2B-9B8E-B53E3AD3E36A/videos/A60460BE-B489-48D0-A5C6-5EAE78E3D0A2/bin

[GET] /api/server/[ID_SERVER]/videos - insere todos os videos de um server
exemplo de request: http://localhost:8080/api/server/04FEFFB2-BEBA-4D73-BBE6-A68E02F63BB8/videos

[recycler]

[POST] /api/recycler/process/[DIAS] - apaga videos com x dias
exemplo de request: http://localhost:8080/api/recycler/process/2

[GET] /api/recycler/status - verifica status da rotina de reciclagem
http://localhost:8080/api/recycler/status



