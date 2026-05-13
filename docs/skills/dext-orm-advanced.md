---
name: dext-orm-advanced
description: Advanced Dext ORM features — entity relationships, inheritance mapping (TPH/TPT), specifications, migrations, raw SQL (FromSql), stored procedures, pessimistic/optimistic locking, multi-tenancy, and JSON column queries.
---

# Dext ORM — Advanced Features

> For basic entity definition, DbContext, CRUD, and Smart Properties, see `dext-orm.md`.

## Relationships

### One-to-Many

```pascal
uses
  Dext.Entity, Dext.Types.Lazy; // ILazy<T>

type
  TUser = class;

  [Table('orders')]
  TOrder = class
  private
    FId: Integer;
    FUserId: Integer;
    FUser: ILazy<TUser>;
    function GetUser: TUser;
    procedure SetUser(const Value: TUser);
  public
    [PK, AutoInc]
    property Id: Integer read FId write FId;

    [ForeignKey('user_id'), BelongsTo]
    property UserId: Integer read FUserId write FUserId;

    // Lazy-loaded navigation
    property User: TUser read GetUser write SetUser; 
  end;

  [Table('users')]
  TUser = class
  private
    FId: Integer;
    FOrders: ILazy<TList<TOrder>>;
    function GetOrders: TList<TOrder>;
  public
    [PK, AutoInc]
    property Id: Integer read FId write FId;

    [InverseProperty('User'), HasMany]
    property Orders: TList<TOrder> read GetOrders;
  end;

// Implementation of Getter/Setter
function TOrder.GetUser: TUser;
begin
  if FUser = nil then FUser := TLazy<TUser>.Create;
  Result := FUser.Value;
end;

procedure TOrder.SetUser(Value: TUser);
begin
  if FUser = nil then FUser := TLazy<TUser>.Create;
  FUser.Value := Value;
  if Value <> nil then FUserId := Value.Id;
end;
```

### Many-to-Many

```pascal
type
  [Table('users')]
  TUser = class
  public
    [ManyToMany('user_roles', 'user_id', 'role_id')]
    property Roles: TList<TRole> read GetRoles;
  end;

  [Table('roles')]
  TRole = class
  public
    [ManyToMany('user_roles', 'role_id', 'user_id')]
    property Users: TList<TUser> read GetUsers;
  end;

// Link / Unlink
Db.Users.LinkManyToMany(User, 'Roles', AdminRole);
Db.Users.UnlinkManyToMany(User, 'Roles', AdminRole);
Db.Users.SyncManyToMany(User, 'Roles', [Role1, Role2]);
Db.SaveChanges;
```

### Include (Eager Loading — Avoid N+1)

```pascal
uses Dext.Entity.Prototype;

var o := Prototype.Entity<TOrder>;

// 1. Type-safe include (Recommended - protects against typos)
var Orders := Db.Orders
  .Include(o.User)
  .Include(o.Items)
  .ToList;

// 2. Deep include (string path)
var Orders := Db.Orders
  .Include(o.User)
  .Include('Items.Product')
  .ToList;
```

### Cascade Delete

```pascal
[ForeignKey('user_id'), OnDeleteCascade]
property UserId: Integer;
```

## Inheritance Mapping

### Table Per Hierarchy (TPH) — Default

All classes share one table; a discriminator column identifies the type:

```pascal
type
  [Table('people'), Inheritance(TablePerHierarchy)]
  [DiscriminatorColumn('person_type')]
  TPerson = class
  private
    FId: Integer;
    FName: string;
  public
    [PK, AutoInc]
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
  end;

  [DiscriminatorValue('student')]
  TStudent = class(TPerson)
  private
    FEnrollment: string;
  public
    property EnrollmentNumber: string read FEnrollment write FEnrollment;
  end;

  [DiscriminatorValue('teacher')]
  TTeacher = class(TPerson)
  private
    FSubject: string;
  public
    property Subject: string read FSubject write FSubject;
  end;

// Polymorphic query — returns TStudent and TTeacher instances
var People := Db.People.ToList;
for var P in People do
  if P is TStudent then
    WriteLn(TStudent(P).EnrollmentNumber);
```

TPH is fast — no JOINs needed for polymorphic queries.

### Table Per Type (TPT) — Normalized Schema

Each class gets its own table, sharing the PK:

```pascal
type
  [Table('vehicles')]
  [Inheritance(TablePerType)]
  TVehicle = class
  private
    FId: Integer;
    FBrand: string;
  public
    [PK]
    property Id: Integer read FId write FId;
    property Brand: string read FBrand write FBrand;
  end;

  [Table('cars')]
  TCar = class(TVehicle)
  private
    FDoors: Integer;
  public
    property NumberOfDoors: Integer read FDoors write FDoors;
  end;
```

## Specifications

Encapsulate reusable, composable query predicates:

```pascal
uses Dext.Specifications;

type
  TActiveAdultSpec = class(TSpecification<TUser>)
  public
    function IsSatisfiedBy(Entity: TUser): Boolean; override;
    function ToExpression: TSpecExpression; override;
  end;

function TActiveAdultSpec.IsSatisfiedBy(Entity: TUser): Boolean;
begin
  Result := Entity.IsActive and (Entity.Age >= 18);
end;

function TActiveAdultSpec.ToExpression: TSpecExpression;
begin
  var u := TUser.Props;
  Result := (u.IsActive = True) and (u.Age >= 18);
end;

// Usage
var Spec := TActiveAdultSpec.Create;
var Users := Db.Users.Where(Spec).ToList;
```

### Combining Specifications

```pascal
var Active := TActiveUserSpec.Create;
var Adult  := TAdultUserSpec.Create;

var Combined := Active.And(Adult);           // AND
var Either   := AdminSpec.Or(ModeratorSpec); // OR
var Inactive := ActiveSpec.Not;              // NOT

// Parameterized
var ByAge := TAgeRangeSpec.Create(MinAge, MaxAge);
```

## Migrations

```pascal
unit Migration_001_CreateUsers;

interface
uses
  Dext.Entity.Migrations;

type
  [Migration(1, 'CreateUsers')]
  TMigration_001_CreateUsers = class(TMigration)
  public
    procedure Up; override;
    procedure Down; override;
  end;

implementation

procedure TMigration_001_CreateUsers.Up;
begin
  CreateTable('users', procedure(T: TTableBuilder)
    begin
      T.AddColumn('id').AsInteger.PrimaryKey.AutoIncrement;
      T.AddColumn('name').AsString(100).NotNull;
      T.AddColumn('email').AsString(255).NotNull.Unique;
      T.AddColumn('created_at').AsDateTime.Default('CURRENT_TIMESTAMP');
    end);
end;

procedure TMigration_001_CreateUsers.Down;
begin
  DropTable('users');
end;
```

### Table Builder API

```pascal
T.AddColumn('id').AsInteger.PrimaryKey.AutoIncrement;
T.AddColumn('name').AsString(100).NotNull;
T.AddColumn('email').AsString(255).Nullable;
T.AddColumn('price').AsDecimal(10, 2).Default('0.00');
T.AddColumn('active').AsBoolean.Default('true');
T.AddColumn('created_at').AsDateTime;
T.AddColumn('data').AsText;           // CLOB/TEXT for large strings
T.AddColumn('binary').AsBlob;         // BLOB
T.AddColumn('uuid').AsGuid;

// Constraints & Indexes
T.AddColumn('email').AsString(255).Unique;
T.AddColumn('status').AsString(20).Check('status IN (''active'', ''inactive'')');
T.AddForeignKey('user_id', 'users', 'id').OnDeleteCascade;
T.AddIndex('idx_email', 'email');
T.AddUniqueIndex('idx_email_unique', 'email');

// Alter
AlterTable('users', procedure(T: TTableBuilder)
  begin
    T.AddColumn('phone').AsString(20).Nullable;
    T.DropColumn('legacy');
    T.RenameColumn('name', 'full_name');
  end);

// Raw SQL
Execute('CREATE INDEX CONCURRENTLY ...');
```

Register migrations — add to the program's `uses` clause:

```pascal
uses
  Migration_001_CreateUsers,
  Migration_002_AddEmailIndex;
// Dext auto-discovers [Migration] attributed classes
```

### Migration CLI

```bash
dext migrate:up               # Apply pending
dext migrate:down             # Rollback last
dext migrate:list             # Show status
dext migrate:generate --name AddOrdersTable
```

## Custom Type Converters

Dext provides a flexible type conversion system to handle data types not supported natively or to customize how Delphi types are stored in the database.

### 1. Attribute-Based Converter

Apply a converter to a specific property using the `[TypeConverter]` attribute.

```pascal
type
  [Table('events')]
  TEvent = class
  private
    FPayload: TJSONObject;
  public
    // Store TJSONObject as string in DB
    [TypeConverter(TJsonConverter)]
    property Payload: TJSONObject read FPayload write FPayload;
  end;
```

### 2. Global Registration

Register a converter globally to handle a specific Delphi type across all entities in your application.

```pascal
uses
  Dext.Entity.TypeConverters;

initialization
  // Option A: Register a general converter (CanConvert will be called)
  TTypeConverterRegistry.Instance.RegisterConverter(TMyGlobalConverter.Create);

  // Option B: Register specifically for a type (most efficient)
  TTypeConverterRegistry.Instance.RegisterConverterForType(
    TypeInfo(TMyCustomType), 
    TMyCustomTypeConverter.Create
  );
```

### Example: Unix Timestamp Converter

```pascal
type
  TUnixTimestampConverter = class(TTypeConverterBase)
  public
    function CanConvert(ATypeInfo: PTypeInfo): Boolean; override;
    function ToDatabase(const AValue: TValue; ADialect: TDatabaseDialect): TValue; override;
    function FromDatabase(const AValue: TValue; ATypeInfo: PTypeInfo): TValue; override;
  end;

function TUnixTimestampConverter.CanConvert(ATypeInfo: PTypeInfo): Boolean;
begin
  Result := ATypeInfo = TypeInfo(TDateTime);
end;

function TUnixTimestampConverter.ToDatabase(const AValue: TValue; ADialect: TDatabaseDialect): TValue;
begin
  Result := DateTimeToUnix(AValue.AsType<TDateTime>);
end;

function TUnixTimestampConverter.FromDatabase(const AValue: TValue; ATypeInfo: PTypeInfo): TValue;
begin
  Result := UnixToDateTime(AValue.AsInt64);
end;
```

## Raw SQL with FromSql

```pascal
// Basic
var Users := Db.Users.FromSql('SELECT * FROM Users WHERE Active = 1').ToList;

// Parameterized (always use params to prevent injection)
var Adults := Db.Users
  .FromSql('SELECT * FROM Users WHERE Age >= :Age', [MinAge])
  .ToList;

// Chain fluent API after FromSql
var List := Db.Users
  .FromSql('SELECT * FROM Users WHERE Role = :Role', ['Admin'])
  .Where(Prop('Active') = True)
  .OrderBy(Prop('Name'))
  .Skip(10).Take(5)
  .ToList;

// Large result sets — streaming
var Query := Db.Users.FromSql('SELECT * FROM Users');
var Iterator := TSqlQueryIterator<TUser>.Create(Query);
try
  while Iterator.Next do
    ProcessUser(Iterator.Current);
finally
  Iterator.Free;
end;
```

`.AsNoTracking` — read-only, not tracked by DbContext.

## Stored Procedures

```pascal
type
  TMyProcs = class
  public
    [StoredProcedure('sp_GetCustomerBalance')]
    procedure GetBalance(
      [DbParam(pdInput)] CustomerId: Integer;
      [DbParam(pdOutput)] out Balance: Currency
    );

    [StoredProcedure('fn_GetActiveCustomers')]
    function GetActiveCustomers(
      [DbParam(pdInput)] RegionId: Integer
    ): IList<TCustomer>;
  end;

// Execute
var Procs := ServiceProvider.GetService<TMyProcs>;
var Balance: Currency;
Procs.GetBalance(123, Balance);

// Multiple result sets
var Results := Db.ExecuteProcedure('sp_GetInvoicesAndItems', [CustomerId]);
var Invoices := Results.Read<TInvoice>;
var Items    := Results.Read<TInvoiceItem>;
```

`[DbParam]` directions: `pdInput`, `pdOutput`, `pdInputOutput`, `pdReturnValue`.

## Locking

### Optimistic (Version Column)

```pascal
type
  [Table('products')]
  TProduct = class
  private
    FId: Integer;
    FVersion: Integer;
  public
    [PK, AutoInc]
    property Id: Integer read FId write FId;

    [Version]
    property Version: Integer read FVersion write FVersion; // Auto-incremented on update
  end;

// On conflict, SaveChanges raises DbUpdateConcurrencyException
```

### Pessimistic (Lock at Query Time)

```pascal
var Product := Db.Products
  .Where(Prop('Id') = 1)
  .Lock(TLockMode.Update)  // FOR UPDATE / UPDLOCK
  .FirstOrDefault;

Product.Price := Product.Price * 1.1;
Db.SaveChanges;
// Lock released when transaction ends
```

| Mode | SQL |
|------|-----|
| `TLockMode.None` | (default) |
| `TLockMode.Update` | `FOR UPDATE` / `UPDLOCK` |
| `TLockMode.Shared` | `FOR SHARE` / `HOLDLOCK` |

## Shadow Properties

Shadow properties are properties that are not defined in your Delphi entity class but are defined in the Dext model for that entity type. They are useful for data that shouldn't clutter your domain model (like `LastModifiedBy` or `IsSystemRecord`).

### Configuration

Override `OnModelCreating` to define shadow properties:

```pascal
procedure TAppDbContext.OnModelCreating(Builder: TModelBuilder);
begin
  Builder.Entity<TProduct>()
    .ShadowProperty('TenantId').HasDbType(ftString).HasMaxLength(50);
end;
```

### Accessing Shadow Values

Since the property doesn't exist in the class, you must use the `DbContext.Entry` API:

```pascal
var Product := Db.Products.Find(1);

// Read
var TenantId := Db.Entry(Product).Member('TenantId').CurrentValue.AsString;

// Write
Db.Entry(Product).Member('TenantId').CurrentValue := 'MyTenant';
Db.SaveChanges;
```

## Multi-Tenancy

### Strategy 1: Shared Database (Column-Based)

```pascal
type
  [Table('orders')]
  TOrder = class(TObject, ITenantAware)
  private
    FId: Integer;
    FTenantId: string;
    FDescription: string;
  public
    [PK]
    property Id: Integer read FId write FId;
    property TenantId: string read FTenantId write FTenantId; // Auto-populated
    property Description: string read FDescription write FDescription;
  end;
  // Or inherit from TTenantEntity
```

Configure in pipeline:

```pascal
App.Builder.UseMultiTenancy(procedure(Options: TMultiTenancyOptions)
  begin
    Options.ResolveFromHeader('X-Tenant'); // or ResolveFromHost
  end);
```

All queries automatically get `WHERE TenantId = 'current-tenant'`.

### Strategy 2: Schema Isolation

```pascal
App.Builder.UseMultiTenancy(procedure(Options: TMultiTenancyOptions)
  begin
    Options.Strategy := TTenancyStrategy.Schema;
    Options.ResolveFromHost; // customer1.myapp.com → schema "customer1"
  end);
```
