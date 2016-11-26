unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls,
  FGL, Math, Types, LCLType, Dialogs;

type
  TTipoCarta = (tcTrebol, tcCorazon, tcBasto, tcDiamante);

const
  TipoCartaStr: array[TTipoCarta] of string = ('Basto', 'Espada', 'Copa', 'Oro');

type

  { TCarta }

  TCarta = class
  private
    FCorrecta: boolean;
    FNumero: integer;
    FTipo: TTipoCarta;
  public
    constructor Create(Numero: integer; Tipo: TTipoCarta);
    function ToString: string; override;
  published
    property Numero: integer read FNumero write FNumero;
    property Tipo: TTipoCarta read FTipo write FTipo;
    property Correcta: boolean read FCorrecta write FCorrecta;
  end;

  TMazo = specialize TFPGObjectList<TCarta>;

  { TfrmMain }

  TfrmMain = class(TForm)
    btnMayor: TButton;
    btnMenor: TButton;
    btnReiniciar: TButton;
    btnCreditos: TButton;
    lblMayorOMenor: TLabel;
    lblPuntos: TLabel;
    ListBoxCartas: TListBox;
    procedure btnCreditosClick(Sender: TObject);
    procedure btnMayorClick(Sender: TObject);
    procedure btnMenorClick(Sender: TObject);
    procedure btnReiniciarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBoxCartasDrawItem(Control: TWinControl; Index: integer;
      ARect: TRect; State: TOwnerDrawState);
  private
    { private declarations }
  public
    { public declarations }
    ProximaCarta: integer;
    Puntos: integer;
    Mazo: TMazo;
    procedure Barajar(List: TFPSList);
    procedure Mostrar;
    procedure MostrarPuntos;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TCarta }

constructor TCarta.Create(Numero: integer; Tipo: TTipoCarta);
begin
  Self.Numero := Numero;
  Self.Tipo := Tipo;
end;

function TCarta.ToString: string;
begin
  Result := IntToStr(Numero) + ' ' + TipoCartaStr[Tipo];
end;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
var
  tipo: TTipoCarta;
  i, j: integer;
begin
  DoubleBuffered := True;

  Self.AutoAdjustLayout(lapAutoAdjustForDPI, Self.DesignTimeDPI,
    Screen.PixelsPerInch, Self.Width, ScaleX(Self.Width, Self.DesignTimeDPI));

  Randomize;

  Mazo := TMazo.Create;

  for i := 0 to 3 do
  begin
    tipo := TTipoCarta(i);
    for j := 1 to 12 do
    begin
      Mazo.Add(TCarta.Create(j, tipo));
    end;
  end;

  btnReiniciarClick(nil);
end;

procedure TfrmMain.btnReiniciarClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to Mazo.Count - 1 do
    Mazo.Items[i].Correcta := False;
  ProximaCarta := 0;
  Puntos := 0;
  ListBoxCartas.Clear;
  Barajar(Mazo);
  Mostrar;
  MostrarPuntos;
end;

procedure TfrmMain.btnMayorClick(Sender: TObject);
begin
  if ProximaCarta < Mazo.Count then
  begin
    if (Mazo.Items[ProximaCarta].Numero >= Mazo.Items[ProximaCarta - 1].Numero) then
    begin
      Mazo.Items[ProximaCarta - 1].Correcta := True;
      Puntos := Puntos + 1;
      ListBoxCartas.Items[ProximaCarta - 1] :=
        Mazo.Items[ProximaCarta].ToString + ' > ' +
        ListBoxCartas.Items[ProximaCarta - 1];
    end
    else
    begin
      ListBoxCartas.Items[ProximaCarta - 1] :=
        Mazo.Items[ProximaCarta].ToString + ' < ' +
        ListBoxCartas.Items[ProximaCarta - 1];
    end;
    Mostrar;
    MostrarPuntos;
  end;
end;

procedure TfrmMain.btnCreditosClick(Sender: TObject);
begin
  ShowMessage('Mayor o Menor por Leandro Diaz (github.com/lainz)');
end;

procedure TfrmMain.btnMenorClick(Sender: TObject);
begin
  if ProximaCarta < Mazo.Count then
  begin
    if (Mazo.Items[ProximaCarta].Numero <= Mazo.Items[ProximaCarta - 1].Numero) then
    begin
      Mazo.Items[ProximaCarta - 1].Correcta := True;
      Puntos := Puntos + 1;
      ListBoxCartas.Items[ProximaCarta - 1] :=
        Mazo.Items[ProximaCarta].ToString + ' < ' +
        ListBoxCartas.Items[ProximaCarta - 1];
    end
    else
    begin
      ListBoxCartas.Items[ProximaCarta - 1] :=
        Mazo.Items[ProximaCarta].ToString + ' > ' +
        ListBoxCartas.Items[ProximaCarta - 1];
    end;
    Mostrar;
    MostrarPuntos;
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  Mazo.Free;
end;

procedure TfrmMain.ListBoxCartasDrawItem(Control: TWinControl;
  Index: integer; ARect: TRect; State: TOwnerDrawState);
begin
  ListBoxCartas.Canvas.Clipping := False;

  if Index < Mazo.Count - 1 then
    if Mazo.Items[Index].Correcta then
      ListBoxCartas.Canvas.Font.Color := clGreen
    else
      ListBoxCartas.Canvas.Font.Color := clRed;

  if Index = ListBoxCartas.Count - 1 then
    ListBoxCartas.Canvas.Font.Color := clBlack;

  if odSelected in State then
    ListBoxCartas.Canvas.Brush.Color := clSilver
  else
    ListBoxCartas.Canvas.Brush.Color := clWhite;

  ListBoxCartas.Canvas.FillRect(ARect);
  ListBoxCartas.Canvas.TextOut(ARect.Left + 10, ARect.Top + 0,
    ListBoxCartas.Items[Index]);

  ListBoxCartas.Canvas.ClipRect := Rect(0, 0, 0, 0);
  ListBoxCartas.Canvas.Clipping := True;
end;

procedure TfrmMain.Barajar(List: TFPSList);
var
  i: integer;
begin
  for i := List.Count - 1 downto 0 do
    List.Exchange(i, RandomRange(0, i));
end;

procedure TfrmMain.Mostrar;
begin
  if ListBoxCartas.Count = Mazo.Count - 1 then
  begin
    ListBoxCartas.Items.Add('¡Juego Terminado!');
    ListBoxCartas.ItemIndex := ListBoxCartas.Count - 1;
    ProximaCarta := ProximaCarta + 1;
  end
  else
  begin
    ListBoxCartas.Items.Add(Mazo.Items[ProximaCarta].ToString);
    ListBoxCartas.ItemIndex := ListBoxCartas.Count - 1;
    ProximaCarta := ProximaCarta + 1;
  end;
end;

procedure TfrmMain.MostrarPuntos;
begin
  lblPuntos.Caption := 'Puntos: ' + IntToStr(Puntos);
end;

end.
