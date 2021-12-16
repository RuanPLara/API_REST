unit uWebModuleMain;

interface

uses
   System.SysUtils, System.Classes, Web.HTTPApp, Rest.Json, System.Json,
   Data.DB, System.IOUtils, System.NetEncoding, System.StrUtils,
   Datasnap.DBClient, System.Generics.Collections, UnControl;

type
   TWMMain = class(TWebModule)
      CDServer: TClientDataSet;
      CDServerID: TStringField;
      CDServerNAME: TStringField;
      CDServerIP: TStringField;
      CDServerPORT: TIntegerField;
      CdArquivos: TClientDataSet;
      CdArquivosID: TStringField;
      CdArquivosNAME: TStringField;
      CdArquivosSIZE: TIntegerField;
      CdArquivosSERVERID: TStringField;

      procedure WMMainIndexAction(Sender: TObject; Request: TWebRequest;
        Response: TWebResponse; var Handled: Boolean);
      procedure WMMainServerAction(Sender: TObject; Request: TWebRequest;
        Response: TWebResponse; var Handled: Boolean);
      procedure CDServerAfterPost(DataSet: TDataSet);
      procedure WMMainServersAction(Sender: TObject; Request: TWebRequest;
        Response: TWebResponse; var Handled: Boolean);
      procedure WMMainStatusServerAction(Sender: TObject; Request: TWebRequest;
        Response: TWebResponse; var Handled: Boolean);
      procedure WebModuleCreate(Sender: TObject);
      procedure WMMainServerVideosAction(Sender: TObject; Request: TWebRequest;
        Response: TWebResponse; var Handled: Boolean);
      procedure WMMainVideosOperationAction(Sender: TObject;
        Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
      procedure CdArquivosAfterPost(DataSet: TDataSet);
   private
      procedure OpenListServer;
      procedure OpenListFiles(Server: String);
      procedure PersistServer(Server: TServer);
      procedure PersistFiles(Arquivo: TArquivo);
      function GetServerId(Id: String): TServer;
      function GetFileId(Server, Id: String): TArquivo;

      function DecodePathUrl(Path: String): TArray<String>;
      procedure FormatGuid(var Guid: String);

      procedure Result400(Mensagem: String);
      procedure Result404();
      { Private declarations }
   public
      { Public declarations }
   end;

var
   WebModuleClass: TComponentClass = TWMMain;

const
   RepoServers: String = '.\servers\';

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TWMMain.CdArquivosAfterPost(DataSet: TDataSet);
begin
   CDServer.SaveToFile(RepoServers + 'list_files.xml', dfXMLUTF8);
end;

procedure TWMMain.CDServerAfterPost(DataSet: TDataSet);
begin
   CDServer.SaveToFile('.\list_servers.xml', dfXMLUTF8);
end;

function TWMMain.DecodePathUrl(Path: String): TArray<String>;
var
   offset: integer;
   count: integer;
   Aux: String;
begin
   if Path[1] = '/' then
      Path := Copy(Path, 2);
   count := 0;
   offset := PosEx('/', Path, 1);
   while offset <> 0 do
   begin
      inc(count);
      offset := PosEx('/', Path, offset + length('/'));
   end;

   SetLength(Result, count + 1);
   Aux := Path;
   for offset := 0 to count do
   begin
      if offset < count then
         Result[offset] := Copy(Aux, 1, Pos('/', Aux) - 1)
      else
         Result[offset] := Aux;
      Aux := Copy(Aux, Pos('/', Aux) + 1);
   end;
end;

procedure TWMMain.FormatGuid(var Guid: String);
begin
   if Guid[1] <> '{' then
      Guid := '{' + Guid + '}';
end;

function TWMMain.GetFileId(Server, Id: String): TArquivo;
begin
   Result := nil;
   if CdArquivosSERVERID.AsString <> Server then
   begin
      CdArquivos.Filtered := False;
      CdArquivos.Filter := 'SERVERID = ' + Server;
      CdArquivos.Filtered := True;
   end;

   if not CdArquivos.IsEmpty then
   begin
      if CdArquivosID.AsString <> Id then
         CdArquivos.Locate('ID', Id, []);
      if CdArquivosID.AsString = Id then
      begin
         Result := TArquivo.Create;
         Result.Id := CdArquivosID.AsString;
         Result.Descricao := CdArquivosNAME.AsString;
         Result.size := CdArquivosSIZE.AsInteger;
         Result.serverId := CdArquivosSERVERID.AsString;
      end;
   end;

end;

function TWMMain.GetServerId(Id: String): TServer;
begin
   Result := nil;
   if CDServerID.AsString <> Id then
      CDServer.Locate('ID', Id, []);
   if CDServerID.AsString = Id then
   begin
      Result := TServer.Create;
      Result.Id := CDServerID.AsString;
      Result.name := CDServerNAME.AsString;
      Result.ip := CDServerIP.AsString;
      Result.port := CDServerPORT.AsInteger;
   end;
end;

procedure TWMMain.OpenListFiles(Server: String);
begin
   if not CdArquivos.Active then
   begin
      if FileExists(RepoServers + 'list_files.xml') then
         CdArquivos.LoadFromFile(RepoServers + 'list_files.xml');
      CdArquivos.Open;
   end;
   CdArquivos.Filtered := false;
   CdArquivos.Filter := 'SERVERID = ' + Server;
   CdArquivos.Filtered := true;
end;

procedure TWMMain.OpenListServer;
begin
   if not CDServer.Active then
   begin
      if FileExists('.\list_servers.xml') then
         CDServer.LoadFromFile('.\list_servers.xml');
      CDServer.Open;
   end;
end;

procedure TWMMain.PersistFiles(Arquivo: TArquivo);
begin
   OpenListFiles(Arquivo.serverId);
   IF not CdArquivos.Locate('ID', Arquivo.Id, []) then
      CdArquivos.Insert
   else
      CdArquivos.edit;

   CdArquivosID.AsString := Arquivo.id;
   CdArquivosNAME.AsString := Arquivo.Descricao;
   CdArquivosSIZE.AsInteger := Arquivo.size;
   CdArquivosSERVERID.AsString := Arquivo.serverId;

   CdArquivos.Post;
   CdArquivos.Close;
end;

procedure TWMMain.PersistServer(Server: TServer);
begin
   OpenListServer;
   IF not CDServer.Locate('ID', Server.Id, []) then
   begin
      CDServer.Insert;

      if not DirectoryExists(RepoServers + Server.Id) then
         ForceDirectories(RepoServers + Server.Id);
   end
   else
      CDServer.edit;

   CDServerID.AsString := Server.Id;
   CDServerNAME.AsString := Server.name;
   CDServerIP.AsString := Server.ip;
   CDServerPORT.AsInteger := Server.port;
   CDServer.Post;
   CDServer.Close;
end;

procedure TWMMain.Result404;
begin
   Response.StatusCode := 404;
   Response.ContentType := 'application/Json';
   Response.Content := TJson.ObjectToJsonString
     (TMessageResult.Create(Request.PathInfo, 'Not found'));
end;

procedure TWMMain.Result400(Mensagem: String);
begin
   if Pos('access violation', lowercase(mensagem)) <> 0 then
   begin
      if Request.MethodType in [mtPut, mtPost] then
         Mensagem := 'Ocorreu um erro ao acessar os dados enviados'
      else
         Mensagem := 'Ocorreu um problema ao processar as informações';
   end;

   Response.StatusCode := 400;
   Response.ContentType := 'application/Json';
   Response.Content := TJson.ObjectToJsonString
     (TMessageResult.Create(Request.PathInfo, Mensagem));
end;

procedure TWMMain.WebModuleCreate(Sender: TObject);
begin
   CDServer.Close;
   CdArquivos.Close;
end;

procedure TWMMain.WMMainIndexAction(Sender: TObject; Request: TWebRequest;
  Response: TWebResponse; var Handled: Boolean);
begin
   if (Request.PathInfo = '/') and (Request.MethodType = mtGET) then
   begin
      Response.StatusCode := 200;
      Response.ContentType := 'application/Json';
      Response.Content := TJson.ObjectToJsonString
        (TMessageResult.Create('API REST', 'Bem vindo a API REST'));
   end
   else
   begin
      Result404;
   end;
end;

procedure TWMMain.WMMainServerAction(Sender: TObject; Request: TWebRequest;
  Response: TWebResponse; var Handled: Boolean);
var
   Server: TServer;
   JsonObject: TJSONObject;
   ListServer: TObjectList<TServer>;
begin
   try
      if Request.MethodType = mtPost then
      begin
         if (Pos('json', Request.ContentType) = 0) then
            raise Exception.Create('Tipo de dados não suportado');

         JsonObject := TJSONObject.ParseJSONValue(Request.Content)
           as TJSONObject;

         if not Assigned(JsonObject) then
            raise Exception.Create('Não foi possível carregar o conteudo JSON');

         Server := TServer.Create;
         Server.Id := TGuid.NewGuid.ToString;
         Server.name := JsonObject.GetValue('name').Value;
         Server.ip := JsonObject.GetValue('ip').Value;
         Server.port := StrToInt(JsonObject.GetValue('port').Value);

         PersistServer(Server);

         Response.StatusCode := 201;
         Response.ContentType := 'application/Json';
         Response.Content := TJson.ObjectToJsonString(Server);

      end
      else
      if Request.MethodType = mtGET then
      begin
         OpenListServer;

         ListServer := TObjectList<TServer>.Create;
         try
            CDServer.First;
            while not CDServer.eof do
            begin
               Server := GetServerId(CDServerID.AsString);
               ListServer.Add(Server);
               CDServer.Next;
            end;

            Response.StatusCode := 201;
            Response.ContentType := 'application/Json';
            Response.Content := TJson.ObjectToJsonString(ListServer);
         finally
            ListServer.Destroy;
         end;
      end
      else
         raise Exception.Create('Método não implementado');
   except
      on e: Exception do
      begin
         Result400(e.Message);
      end;
   end;
end;

procedure TWMMain.WMMainServersAction(Sender: TObject; Request: TWebRequest;
  Response: TWebResponse; var Handled: Boolean);
var
   FindGuid: String;
   Server: TServer;
   JsonObject: TJSONObject;
begin
   try
      FindGuid := DecodePathUrl(Request.PathInfo)[2];
      // FindGuid := Copy(Request.PathInfo,
      // LastDelimiter('/', Request.PathInfo) + 1);

      try
         FormatGuid(FindGuid);

         OpenListServer;
         Server := GetServerId(FindGuid);
         if not Assigned(Server) then
            raise Exception.Create('');
      except
         on e: Exception do
         begin
            Result404;
            exit;
         end;
      end;

      if Request.MethodType = mtPut then
      begin
         JsonObject := TJSONObject.ParseJSONValue(Request.Content)
           as TJSONObject;

         if not Assigned(JsonObject) then
            raise Exception.Create('Não foi possível carregar o conteudo JSON');

         OpenListServer;

         Server := GetServerId(FindGuid);
         if Server = nil then
         begin
            Result404;
            exit
         end;
         Server.name := JsonObject.GetValue('name').Value;
         Server.ip := JsonObject.GetValue('ip').Value;
         Server.port := StrToInt(JsonObject.GetValue('port').Value);

         PersistServer(Server);

         Response.StatusCode := 201;
         Response.ContentType := 'application/Json';
         Response.Content := TJson.ObjectToJsonString(Server);

      end
      else if Request.MethodType = mtDelete then
      begin
         if DirectoryExists(RepoServers + CDServerID.AsString) then
            RemoveDir(RepoServers + CDServerID.AsString);

         if CDServerID.AsString = FindGuid then
            CDServer.Delete;

         Response.StatusCode := 202;
         Response.ContentType := 'application/Json';
         Response.Content := TJson.ObjectToJsonString(Server);
      end
      else if Request.MethodType = mtGET then
      begin
         Response.StatusCode := 201;
         Response.ContentType := 'application/Json';
         Response.Content := TJson.ObjectToJsonString(Server);
      end
      else
         raise Exception.Create('Método não disponivel');
   except
      on e: Exception do
      begin
         Result400(e.Message);
      end;
   end;
end;

procedure TWMMain.WMMainServerVideosAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
   JsonObject: TJSONObject;
   ArquivoObj: TArquivo;
   // Arquivo : TFile;
   inStream: TFileStream;
   outStream: TFileStream;
   Server: String;
   Buff: TBytes;
begin
   try
      Server := DecodePathUrl(Request.PathInfo)[2];

      if Request.MethodType = mtPost then
      begin

         JsonObject := TJSONObject.ParseJSONValue(Request.Content)
           as TJSONObject;

         if not Assigned(JsonObject) then
            raise Exception.Create('Não foi possível carregar o conteudo JSON');

         ArquivoObj := TArquivo.Create;
         ArquivoObj.Id := TGuid.NewGuid.ToString;
         ArquivoObj.serverId := Server;

         ArquivoObj.Descricao := JsonObject.GetValue('descricao').Value;
         ArquivoObj.base64 := JsonObject.GetValue('base64').Value;
         ArquivoObj.size := StrToInt(JsonObject.GetValue('size').Value);

         if FileExists(RepoServers + ArquivoObj.Id + '.bin') then
            DeleteFile(RepoServers + ArquivoObj.Id + '.bin');

         if FileExists(RepoServers + ArquivoObj.Id + ArquivoObj.TipoArquivo) then
            DeleteFile(RepoServers + ArquivoObj.Id+ ArquivoObj.TipoArquivo);

         Tfile.AppendAllText(RepoServers + ArquivoObj.Id + '.bin', ArquivoObj.base64);

         inStream := TFileStream.Create(RepoServers + ArquivoObj.Id + '.bin', fmOpenRead);

         outStream := TFileStream.Create(RepoServers + ArquivoObj.Id+ ArquivoObj.TipoArquivo,
           fmCreate);
         try
            TNetEncoding.base64.Decode(inStream, outStream);
         finally
            outStream.Free;
         end;

         if FileExists(RepoServers + ArquivoObj.Id + '.bin') then
            DeleteFile(RepoServers + ArquivoObj.Id + '.bin');

         // devolve o objeto sem trafegar todo o arquivo novamente
         ArquivoObj.base64 := '[ACCEPT]';
         Response.StatusCode := 201;
         Response.ContentType := 'application/Json';
         Response.Content := TJson.ObjectToJsonString(ArquivoObj);

      end;
   except
      on e: Exception do
         Result400(e.Message)
   end;
end;

procedure TWMMain.WMMainStatusServerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
   FindGuid: String;
   Server: TServer;
begin
   try
      FindGuid := DecodePathUrl(Request.PathInfo)[3];
      // Copy(Request.PathInfo,
      // LastDelimiter('/', Request.PathInfo) + 1);

      FormatGuid(FindGuid);

      OpenListServer;
      Server := GetServerId(FindGuid);
      if not Assigned(Server) then
      begin
         Response.StatusCode := 404;
         Response.ContentType := 'application/Json';
         Response.Content := TJson.ObjectToJsonString
           (TMessageResult.Create(FindGuid, 'NOT FOUND'));
      end
      else if NOT DirectoryExists(RepoServers + FindGuid) then
      begin
         Response.StatusCode := 201;
         Response.ContentType := 'application/Json';
         Response.Content := TJson.ObjectToJsonString
           (TMessageResult.Create(FindGuid, 'OFF LINE'));
         exit;
      end
      else
      begin
         Response.StatusCode := 201;
         Response.ContentType := 'application/Json';
         Response.Content := TJson.ObjectToJsonString
           (TMessageResult.Create(FindGuid, 'ON LINE'));
         exit;
      end;
   except
      on e: Exception do
         Result400(e.Message);
   end;
end;

procedure TWMMain.WMMainVideosOperationAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
   Response.StatusCode := 201;
   Response.Content := Request.Content;
end;

end.
