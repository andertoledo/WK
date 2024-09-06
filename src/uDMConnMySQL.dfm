object DMConnMySQL: TDMConnMySQL
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 178
  Width = 350
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=wk'
      'User_Name=root'
      'Password=My232323@#'
      'DriverID=MySQL')
    Connected = True
    LoginPrompt = False
    Left = 144
    Top = 48
  end
end
