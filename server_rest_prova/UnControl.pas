unit UnControl;

interface

uses System.SysUtils;

type
   TMessageResult = Class
   private
      FMessage: String;
      FTitle: string;
      procedure SetMessage(const Value: String);
      procedure SetTitle(const Value: string);
   public
      constructor Create(vTitle, vMessage: String);
      property Title: string read FTitle write SetTitle;
      property Message: String read FMessage write SetMessage;
   end;

   TServer = class
   private
      Fname: String;
      Fid: String;
      Fport: integer;
      Fip: string;
      procedure Setid(const Value: String);
      procedure Setip(const Value: string);
      procedure Setname(const Value: String);
      procedure Setport(const Value: integer);
   public
      property id: String read Fid write Setid;
      property name: String read Fname write Setname;
      property ip: string read Fip write Setip;
      property port: integer read Fport write Setport;
   end;

   TArquivo = class
   private
      FDescricao: string;
      Fbase64: string;
      Fsize: integer;
      Fid: String;
    FserverId: String;
    FTipoArquivo: String;
      procedure Setbase64(const Value: string);
      procedure SetDescricao(const Value: string);
      procedure Setsize(const Value: integer);
      procedure Setid(const Value: String);
    procedure SetserverId(const Value: String);
   public
      property id: String read Fid write Setid;
      property Descricao: string read FDescricao write SetDescricao;
      property base64: string read Fbase64 write Setbase64;
      property size: integer read Fsize write Setsize;
      property serverId : String read FserverId write SetserverId;
      property TipoArquivo : String read FTipoArquivo;
   end;

implementation

{ TMessageResult }

constructor TMessageResult.Create(vTitle, vMessage: String);
begin
   inherited Create;
   Self.FTitle := vTitle;
   Self.FMessage := vMessage;
end;

procedure TMessageResult.SetMessage(const Value: String);
begin
   FMessage := Value;
end;

procedure TMessageResult.SetTitle(const Value: string);
begin
   FTitle := Value;
end;

{ TServer }

procedure TServer.Setid(const Value: String);
begin
   Fid := Value;
end;

procedure TServer.Setip(const Value: string);
begin
   Fip := Value;
end;

procedure TServer.Setname(const Value: String);
begin
   Fname := Value;
end;

procedure TServer.Setport(const Value: integer);
begin
   Fport := Value;
end;

{ TArquivo }

procedure TArquivo.Setbase64(const Value: string);
begin
   Fbase64 := Value;
end;

procedure TArquivo.SetDescricao(const Value: string);
begin
   FDescricao := Value;
   FTipoArquivo := ExtractFileExt(Value);
end;

procedure TArquivo.Setid(const Value: String);
begin
   Fid := Value;
end;

procedure TArquivo.SetserverId(const Value: String);
begin
  FserverId := Value;
end;

procedure TArquivo.Setsize(const Value: integer);
begin
   Fsize := Value;
end;

end.
