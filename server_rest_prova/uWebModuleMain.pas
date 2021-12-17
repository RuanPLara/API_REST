unit uWebModuleMain;

interface

uses
   System.SysUtils, System.Classes, Web.HTTPApp, Rest.Json, System.Json,
   Data.DB, System.IOUtils, System.NetEncoding, System.StrUtils, System.Types,
   Datasnap.DBClient, System.Generics.Collections, UnControl, System.Threading;

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
      procedure WMMainRecuperaBinVideoAction(Sender: TObject;
        Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
      procedure WMMainApagaVideosAction(Sender: TObject; Request: TWebRequest;
        Response: TWebResponse; var Handled: Boolean);
    procedure WMMainStatusReciclagemAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
   private
      procedure OpenListServer;
      procedure OpenListFiles(Server: String);
      procedure PersistServer(Server: TServer);
      procedure PersistFiles(Arquivo: TArquivo);
      function GetServerId(Id: String): TServer;
      function GetFileId(Server, Id: String): TArquivo;
      procedure SaveFileInServer(Arquivo: TArquivo);
      procedure ConvertBinToFile(Arquivo: TArquivo);

      function DecodePathUrl(Path: String): TArray<String>;
      procedure FormatGuid(var Guid: String);
      procedure DeletarDiretorio(const NomeDiretorio: string);

      procedure Result400(Mensagem: String);
      procedure Result404();
      function TaskStatusToStr(Status : TTaskStatus) : String;
      { Private declarations }
   public
      { Public declarations }
   end;

var
   WebModuleClass: TComponentClass = TWMMain;
   recycler: IFuture<integer>;

const
   RepoServers: String = '.\servers\';

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TWMMain.CdArquivosAfterPost(DataSet: TDataSet);
begin
   CdArquivos.SaveToFile(RepoServers + 'list_files.xml', dfXMLUTF8);
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

procedure TWMMain.DeletarDiretorio(const NomeDiretorio: string);
var
   arquivos: TStringDynArray;
   Arquivo: string;
begin
   if TDirectory.Exists(NomeDiretorio) then
   begin
      // obtem todos os arquivos dentro do diretório.
      arquivos := TDirectory.GetFiles(NomeDiretorio);

      // deleta todos os arquivos.
      for Arquivo in arquivos do
      begin
         TFile.Delete(Arquivo);
      end;

      // se não existir mais arquivos, remove o diretorio.
      if TDirectory.IsEmpty(NomeDiretorio) then
      begin
         TDirectory.Delete(NomeDiretorio);
      end;
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
      CdArquivos.Filter := 'SERVERID = ' + QuotedStr(Server);
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
   CdArquivos.Filtered := False;
   CdArquivos.Filter := 'SERVERID = ' + QuotedStr(Server);
   CdArquivos.Filtered := True;
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

   CdArquivosID.AsString := Arquivo.Id;
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

procedure TWMMain.ConvertBinToFile(Arquivo: TArquivo);
var
   inStream: TFileStream;
   outStream: TFileStream;
   Buff: TBytes;
begin
   if FileExists(RepoServers + Arquivo.serverId + '\' + Arquivo.Id +
     Arquivo.TipoArquivo) then
      DeleteFile(RepoServers + Arquivo.serverId + '\' + Arquivo.Id +
        Arquivo.TipoArquivo);

   inStream := TFileStream.Create(RepoServers + Arquivo.serverId + '\' +
     Arquivo.Id + '.bin', fmOpenRead);

   outStream := TFileStream.Create(RepoServers + Arquivo.serverId + '\' +
     Arquivo.Id + Arquivo.TipoArquivo, fmCreate);
   try
      TNetEncoding.base64.Decode(inStream, outStream);
   finally
      outStream.Free;
      inStream.Free;
   end;
end;

procedure TWMMain.SaveFileInServer(Arquivo: TArquivo);
begin
   if FileExists(RepoServers + Arquivo.serverId + '\' + Arquivo.Id + '.bin')
   then
      DeleteFile(RepoServers + Arquivo.serverId + '\' + Arquivo.Id + '.bin');

   TFile.AppendAllText(RepoServers + Arquivo.serverId + '\' + Arquivo.Id +
     '.bin', Arquivo.base64);
end;

function TWMMain.TaskStatusToStr(Status: TTaskStatus): String;
begin
   case Ord(Status) of
      0 : Result := 'Created';
      1 : Result :='WaitingToRun';
      2 : Result :='Running';
      3 : Result :='Completed';
      4 : Result :='WaitingForChildren';
      5 : Result :='Canceled';
      6 : Result :='Exception';
   end;
end;

procedure TWMMain.Result400(Mensagem: String);
begin
   if Pos('access violation', lowercase(Mensagem)) <> 0 then
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

procedure TWMMain.WMMainApagaVideosAction(Sender: TObject; Request: TWebRequest;
  Response: TWebResponse; var Handled: Boolean);
var
   dias: integer;
begin

   try
      dias := StrToIntDef(DecodePathUrl(Request.PathInfo)[3], 0);
      if dias <= 0 then
         raise Exception.Create('Parametro inválido');

      recycler := TTask.Future<integer>(
         function: integer
         var
            RepoArquivos: TClientDataSet;
            FHandle: integer;
            Arquivo: String;
            DataArquivo: TDateTime;
         begin
            try
               RepoArquivos := TClientDataSet.Create(Self);
               RepoArquivos.LoadFromFile(RepoServers + 'list_files.xml');
               RepoArquivos.Open;

               RepoArquivos.First;
               while not RepoArquivos.Eof do
               begin
                  Arquivo := RepoServers + RepoArquivos.FieldByName('SERVERID')
                    .AsString + '\' + RepoArquivos.FieldByName('ID')
                    .AsString + '.bin';
                  if FileExists(Arquivo) then
                  begin
                     FHandle := FileOpen(Arquivo, 0);
                     try
                        DataArquivo := FileDateToDateTime(FileGetDate(FHandle));
                     finally
                        FileClose(FHandle);
                     end;
                     if DataArquivo < (Date - dias) then
                     begin
                        DeleteFile(Arquivo);
                     end;
                  end;

                  RepoArquivos.Next;
               end;
               Result := 201;
            except
               Result := 500;
            end;
         end);

      if Assigned(recycler) then
      begin
         Response.StatusCode := 201;
         Response.Content := TJson.ObjectToJsonString(TMessageResult.Create('Reciclagem iniciada', TaskStatusToStr(recycler.Status)));
      end
      else
      begin
         Response.StatusCode := 500;
         Response.Content := TJson.ObjectToJsonString(TMessageResult.Create('Reciclagem', 'Não foi possível iniciar a rotina de reciclagem'));
      end;
   except
      on e: Exception do
         Result400(e.Message)
   end;
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

procedure TWMMain.WMMainRecuperaBinVideoAction(Sender: TObject;
Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
   ArrayPath: TArray<String>;
   Server, IdFile: String;

   ArquivoObj: TArquivo;
begin
   try
      ArrayPath := DecodePathUrl(Request.PathInfo);
      Server := ArrayPath[2];
      IdFile := ArrayPath[4];
      FormatGuid(Server);
      FormatGuid(IdFile);

      OpenListServer;
      OpenListFiles(Server);
      if not Assigned(GetServerId(Server)) then
      begin
         raise Exception.Create('Server ' + Server + ' OFF LINE');
      end;

      ArquivoObj := GetFileId(Server, IdFile);
      if not Assigned(ArquivoObj) then
      begin
         Result404;
         exit;
      end;

      if Request.MethodType = mtGET then
      begin
         if not FileExists(RepoServers + ArquivoObj.serverId + '\' +
           ArquivoObj.Id + '.bin') then
         begin
            Result404;
            exit;
         end
         else if Pos('html', Request.Accept) <> 0 then
         begin
            Response.StatusCode := 201;
         end
         else
         begin
            Response.StatusCode := 201;
            Response.Content :=
              TFile.ReadAllText(RepoServers + ArquivoObj.serverId + '\' +
              ArquivoObj.Id + '.bin');
         end;
      end
      else
         raise Exception.Create('Método não implementado');

   except
      on e: Exception do
         Result400(e.Message);
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
      else if Request.MethodType = mtGET then
      begin
         OpenListServer;

         ListServer := TObjectList<TServer>.Create;
         try
            CDServer.First;
            while not CDServer.Eof do
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
            DeletarDiretorio(RepoServers + CDServerID.AsString);

         OpenListFiles(FindGuid);
         CdArquivos.First;
         while NOT CdArquivos.Eof do
            CdArquivos.Delete;

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
   Server: String;
   ListFiles: TObjectList<TArquivo>;
begin
   try
      Server := DecodePathUrl(Request.PathInfo)[2];
      FormatGuid(Server);
      OpenListServer;
      if not Assigned(GetServerId(Server)) then
      begin
         raise Exception.Create('Server ' + Server + ' OFF LINE');
      end;

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

         SaveFileInServer(ArquivoObj);

         PersistFiles(ArquivoObj);

         // devolve o objeto sem trafegar todo o arquivo novamente
         ArquivoObj.base64 := '[ACCEPT]';
         Response.StatusCode := 201;
         Response.ContentType := 'application/Json';
         Response.Content := TJson.ObjectToJsonString(ArquivoObj);

      end
      else
      begin
         OpenListFiles(Server);
         ListFiles := TObjectList<TArquivo>.Create;
         try
            CdArquivos.First;
            while not CdArquivos.Eof do
            begin
               ArquivoObj := GetFileId(Server, CdArquivosID.AsString);
               ListFiles.Add(ArquivoObj);
               CdArquivos.Next;
            end;

            Response.StatusCode := 201;
            Response.ContentType := 'application/Json';
            Response.Content := TJson.ObjectToJsonString(ListFiles);
         finally
            ListFiles.Destroy;
         end;
      end;
   except
      on e: Exception do
         Result400(e.Message)
   end;
end;

procedure TWMMain.WMMainStatusReciclagemAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
   try
      Response.StatusCode := 201;
      if not Assigned(recycler) then
      begin
         Response.Content := '{"status": "stop"}';
      end
      else
         Response.Content := '{"status": "'+TaskStatusToStr(recycler.Status)+'"}';
   except
      on e:exception do
         Result400(e.Message);
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
var
   ArrayPath: TArray<String>;
   Server, IdFile: String;

   ArquivoObj: TArquivo;
begin
   try
      ArrayPath := DecodePathUrl(Request.PathInfo);
      Server := ArrayPath[2];
      IdFile := ArrayPath[4];
      FormatGuid(Server);
      FormatGuid(IdFile);

      OpenListServer;
      OpenListFiles(Server);
      if not Assigned(GetServerId(Server)) then
      begin
         raise Exception.Create('Server ' + Server + ' OFF LINE');
      end;

      ArquivoObj := GetFileId(Server, IdFile);
      if not Assigned(ArquivoObj) then
      begin
         Result404;
         exit;
      end;

      if Request.MethodType = mtGET then
      begin
         Response.StatusCode := 201;
         Response.Content := TJson.ObjectToJsonString(ArquivoObj);
      end
      else if Request.MethodType = mtDelete then
      begin
         if (CdArquivosSERVERID.AsString = Server) and
           (CdArquivosID.AsString = IdFile) then
            CdArquivos.Delete;

         if FileExists(RepoServers + ArquivoObj.serverId + '\' + ArquivoObj.Id +
           '.bin') then
            DeleteFile(RepoServers + ArquivoObj.serverId + '\' + ArquivoObj.Id
              + '.bin');

         Response.StatusCode := 202;
         Response.Content := TJson.ObjectToJsonString(ArquivoObj);
      end
      else
         raise Exception.Create('Método não implementado');

   except
      on e: Exception do
         Result400(e.Message);
   end;
end;

end.
