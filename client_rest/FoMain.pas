unit FoMain;

interface

uses
   Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
   System.Classes, Vcl.Graphics, Rest.Json, IOUtils,
   Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.NetEncoding,
   IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type
   TForm1 = class(TForm)
      OpenDialog1: TOpenDialog;
      BtCarregaArquivo: TButton;
      MmBase64: TMemo;
      BtEnviaArquivo: TButton;
      IdHTTP1: TIdHTTP;
      GroupBox1: TGroupBox;
      EdServer: TEdit;
      Label1: TLabel;
      Label2: TLabel;
      EdApi: TEdit;
    Button1: TButton;
      procedure BtCarregaArquivoClick(Sender: TObject);
      procedure BtEnviaArquivoClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

   TArquivo = class
   private
      FDescricao: string;
      Fbase64: string;
      Fsize: integer;
      procedure Setbase64(const Value: string);
      procedure SetDescricao(const Value: string);
      procedure Setsize(const Value: integer);
   public
      property Descricao: string read FDescricao write SetDescricao;
      property base64: string read Fbase64 write Setbase64;
      property size: integer read Fsize write Setsize;
   end;

var
   Form1: TForm1;

   Arquivo: TArquivo;

implementation

{$R *.dfm}

procedure TForm1.BtCarregaArquivoClick(Sender: TObject);
var
   inStream: TStream;
   outStream: TFileStream;
   size: integer;
begin
   OpenDialog1.InitialDir := ExtractFilePath(Application.ExeName);
   if OpenDialog1.Execute() then
   begin
      inStream := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
      try
         if not DirectoryExists('.\videos') then
            ForceDirectories('.\videos');
         outStream := TFileStream.Create('.\videos\file.bin', fmCreate);
         try
            TNetEncoding.base64.Encode(inStream, outStream);
            size := outStream.size
         finally
            outStream.Free;
         end;

         if size > 0 then
         begin
            MmBase64.Lines.LoadFromFile('.\videos\file.bin');

            Arquivo := TArquivo.Create;
            Arquivo.Descricao := ExtractFileName(OpenDialog1.FileName);
            Arquivo.base64 := MmBase64.Lines.Text;
            Arquivo.size := size;
         end;
      finally
         inStream.Free;
      end;
   end;
end;

{ TArquivo }

procedure TArquivo.Setbase64(const Value: string);
begin
   Fbase64 := Value;
end;

procedure TArquivo.SetDescricao(const Value: string);
begin
   FDescricao := Value;
end;

procedure TArquivo.Setsize(const Value: integer);
begin
   Fsize := Value;
end;

procedure TForm1.BtEnviaArquivoClick(Sender: TObject);
var
   IdHTTP: TIdHTTP;
   Envio: TStringStream;
begin
   IdHTTP := TIdHTTP.Create(Application);

   Envio := TStringStream.Create;
   Envio.WriteString(TJson.ObjectToJsonString(Arquivo));
   Envio.Position := 0;

   Envio.SaveToFile('.\request.json');

   try
      MmBase64.Text := IdHTTP.Post(EdApi.Text + '/api/server/' + EdServer.Text +
        '/videos', Envio);
   except
      on e: EIdHTTPProtocolException do
         MessageDlg('não foi possivel enviar o arquivo ' + IntToStr(e.ErrorCode)
           + ' ' + e.ErrorMessage, MtError, [mbok], 0);

   end;

end;

procedure TForm1.Button1Click(Sender: TObject);
var InStream : TFileStream;
    outStream : TFileStream;
begin
   if FileExists('.\arquivo.bin') then
      DeleteFile('.\arquivo.bin');
   if FileExists('.\arquivo.mp4') then
      DeleteFile('.\arquivo.mp4');

   MmBase64.Lines.SaveToFile('.\arquivo.bin');
   InStream := TFileStream.Create('.\arquivo.bin', fmOpenRead);

   outStream := TFileStream.Create('.\arquivo.mp4', fmCreate);
   try
      TNetEncoding.base64.Decode(inStream, outStream);
   finally
      outStream.Free;
   end;


end;

end.
