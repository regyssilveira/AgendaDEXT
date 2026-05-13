---
name: dext-desktop-ui
description: Build VCL desktop applications with the Dext UI framework — Navigator for Flutter-inspired view management, Magic Binding for declarative two-way data binding, and MVVM architecture patterns.
---

# Dext Desktop UI

Flutter-inspired navigation and declarative binding for VCL desktop applications.

## Core Imports

```pascal
uses
  Dext.UI;          // TSimpleNavigator, INavigator, TBindingEngine
  Dext.UI.Binding;  // TBindingEngine, binding attribute types
```

> 📦 Example: `Desktop.MVVM.CustomerCRUD`

---

## Navigator Framework

### Setup

```pascal
var Navigator := TSimpleNavigator.Create;
Navigator.UseAdapter(TCustomContainerAdapter.Create(ContentPanel));
```

### Navigation Methods

```pascal
Navigator.Push(TCustomerListFrame);              // Push new view
Navigator.Push(TCustomerEditFrame,               // Push with data
  TValue.From(Customer));
Navigator.Pop;                                    // Go back
Navigator.Replace(TNewView);                      // Replace current
Navigator.PopUntil(THomeView);                    // Pop to specific type
```

### Receive Data in Target Frame

Implement `INavigationAware`:

```pascal
type
  TCustomerEditFrame = class(TFrame, INavigationAware)
  public
    procedure OnNavigatedTo(const Context: TNavigationContext);
    procedure OnNavigatedFrom;
  end;

procedure TCustomerEditFrame.OnNavigatedTo(const Context: TNavigationContext);
begin
  if Context.HasValue then
    LoadCustomer(Context.Value.AsType<TCustomer>);
end;

procedure TCustomerEditFrame.OnNavigatedFrom;
begin
  // Cleanup or save state
end;
```

### Navigation Middleware

```pascal
// Auth guard
type
  TAuthMiddleware = class(TInterfacedObject, INavigationMiddleware)
  private
    FAuthService: IAuthService;
  public
    function Execute(const Context: TNavigationContext;
      Next: TNavigationDelegate): TNavigationResult;
  end;

function TAuthMiddleware.Execute(const Ctx: TNavigationContext;
  Next: TNavigationDelegate): TNavigationResult;
begin
  if not FAuthService.IsAuthenticated then
    Result := TNavigationResult.Blocked('Not authenticated')
  else
    Result := Next(Ctx);
end;

// Register middlewares
Navigator
  .UseMiddleware(TLoggingMiddleware.Create(Logger))
  .UseMiddleware(TAuthMiddleware.Create(AuthService));
```

### Adapters

```pascal
Navigator.UseAdapter(TCustomContainerAdapter.Create(ContentPanel)); // Embed in panel
Navigator.UseAdapter(TPageControlAdapter.Create(PageControl1));     // Tabs
Navigator.UseAdapter(TMDIAdapter.Create(Application));              // MDI windows
```

### DI Integration

```pascal
Services.AddSingleton<ISimpleNavigator>(
  function(P: IServiceProvider): TObject
  begin
    var Nav := TSimpleNavigator.Create;
    Nav.UseAdapter(TCustomContainerAdapter.Create(MainForm.ContentPanel));
    Result := Nav;
  end);
```

---

## Magic Binding

Declarative two-way binding between VCL controls and ViewModel properties via RTTI attributes. Controls must be in the `published` section.

### Binding Attributes

```pascal
type
  TCustomerEditFrame = class(TFrame)
  private
    FViewModel: TCustomerViewModel;
    FBindingEngine: TBindingEngine;
  published
    [BindEdit('Name')]          // TEdit ↔ ViewModel.Name (two-way)
    NameEdit: TEdit;

    [BindEdit('Email')]
    EmailEdit: TEdit;

    [BindText('ErrorMessage')]  // TLabel ← ViewModel.ErrorMessage (one-way)
    ErrorLabel: TLabel;

    [BindCheckBox('IsActive')]  // TCheckBox ↔ ViewModel.IsActive
    ActiveCheck: TCheckBox;

    [OnClickMsg(TSaveMsg)]      // Button click → dispatch TSaveMsg
    SaveButton: TButton;

    [OnClickMsg(TCancelMsg)]
    CancelButton: TButton;
  end;
```

| Attribute | Control | Direction |
|-----------|---------|-----------|
| `[BindEdit('Prop')]` | TEdit | Two-way |
| `[BindText('Prop')]` | TLabel | One-way (read) |
| `[BindCheckBox('Prop')]` | TCheckBox | Two-way |
| `[OnClickMsg(TMsgClass)]` | TButton | Click → message dispatch |

### Setup and Refresh

```pascal
procedure TCustomerEditFrame.AfterConstruction;
begin
  inherited;
  FBindingEngine := TBindingEngine.Create(Self, FViewModel);
end;

// Call after ViewModel data changes externally
procedure TCustomerEditFrame.LoadCustomer(Customer: TCustomer);
begin
  FViewModel.Load(Customer);
  FBindingEngine.Refresh;
end;
```

### Nested Properties (Dot Notation)

```pascal
[BindEdit('Customer.Address.City')]
CityEdit: TEdit;

[BindText('Errors.Text')]
ErrorsLabel: TLabel;
```

### Custom Type Converters

```pascal
type
  TCurrencyConverter = class(TInterfacedObject, IValueConverter)
    function Convert(const Value: TValue): TValue;
    function ConvertBack(const Value: TValue): TValue;
  end;

[BindEdit('Price', TCurrencyConverter)]
PriceEdit: TEdit;
```

---

## MVVM Architecture

### Recommended Structure

```
Features/
├── Customers/
│   ├── Customer.Entity.pas        # ORM entity
│   ├── Customer.Service.pas       # Business logic interface + impl
│   ├── Customer.Controller.pas    # Orchestrator (actions → service → view)
│   ├── Customer.ViewModel.pas     # Wraps entity, adds validation + UI state
│   ├── Customer.Rules.pas         # Pure validation logic (testable)
│   ├── Customer.List.pas          # TFrame — list view
│   └── Customer.Edit.pas          # TFrame — edit view
```

### ViewModel Pattern

```pascal
type
  TCustomerViewModel = class
  private
    FCustomer: TCustomer;
    FErrors: TStrings;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load(Customer: TCustomer; AOwnsCustomer: Boolean = False);
    procedure Clear;
    function Validate: Boolean;
    function GetEntity: TCustomer;

    // Bindable properties
    property Name: string read GetName write SetName;
    property Email: string read GetEmail write SetEmail;
    property IsNew: Boolean read GetIsNew;
    property Errors: TStrings read FErrors;
  end;

function TCustomerViewModel.Validate: Boolean;
var Errors: TArray<string>;
begin
  FErrors.Clear;
  Result := TCustomerRules.ValidateAll(FCustomer, Errors);
  for var E in Errors do
    FErrors.Add(E);
end;
```

### Controller Pattern

```pascal
type
  ICustomerController = interface
    procedure SetView(View: ICustomerView);
    procedure LoadCustomers;
    procedure SaveCustomer;
    procedure DeleteCustomer(Id: Integer);
  end;

  TCustomerController = class(TInterfacedObject, ICustomerController)
  private
    FService: ICustomerService;
    FNavigator: ISimpleNavigator;
    FView: ICustomerView;
  public
    constructor Create(Service: ICustomerService; Navigator: ISimpleNavigator);
  end;
```

### View Interface (Enables Mocking)

```pascal
type
  {$M+}  // REQUIRED for Mock<ICustomerView> to work
  ICustomerView = interface
    ['{...}']
    procedure RefreshList(Customers: IList<TCustomer>);
    procedure ShowEditView(ViewModel: TCustomerViewModel);
    procedure ShowError(const Msg: string);
  end;
  {$M-}
```

> Use `{$M+}` on any interface you plan to mock in tests.

### DI Registration

```pascal
Services
  .AddScoped<ICustomerService, TCustomerService>
  .AddScoped<ICustomerController, TCustomerController>
  .AddSingleton<ISimpleNavigator>(NavigatorFactory);
```

