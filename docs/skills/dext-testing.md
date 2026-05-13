---
name: dext-testing
description: Write unit tests with the Dext Testing Framework — test fixtures, mocking interfaces, fluent assertions, and running tests.
---

# Dext Testing Framework

## Core Imports

```pascal
uses
  Dext.Testing; // Facade: Assert, Should, TTest, [TestFixture], [Test], etc.
  Dext.Mocks;   // Mock<T> — NOT included in Dext.Testing facade
```

> `Mock<T>` lives in `Dext.Mocks`, not in the `Dext.Testing` facade.
> Import both when writing tests with mocks.

## Test Project Structure (`.dpr`)

Create a separate **Console Application** project for tests:

```pascal
program MyProject.Tests;

{$APPTYPE CONSOLE}

uses
  Dext.MM,          // Optional: FastMM5 memory manager
  Dext.Utils,       // SetConsoleCharSet, ConsolePause
  System.SysUtils,
  Dext.Testing,     // Main facade
  TUserServiceTests in 'UserServiceTests.pas',
  TOrderTests in 'OrderTests.pas';

begin
  SetConsoleCharSet;  // REQUIRED for all console projects

  TTest.SetExitCode(
    TTest.Configure
      .Verbose            // REQUIRED: without this, output is silent
      .RegisterFixtures([TUserServiceTests, TOrderTests])
      .Run
  );

  ConsolePause;  // Keeps console open in IDE
end.
```

## Test Fixture — Attributes

```pascal
uses
  Dext.Testing;

type
  [TestFixture]
  TUserServiceTests = class
  public
    [Setup]
    procedure Setup;       // Runs before each test

    [TearDown]
    procedure TearDown;    // Runs after each test

    [Test]
    procedure Should_ReturnUser_WhenExists;

    [Test]
    [TestCase(1, 2, 3)]    // Parameters: A=1, B=2, Expected=3
    [TestCase(10, 5, 15)]
    procedure Should_Add_WithParams(A, B, Expected: Integer);
  end;
```

## Mocking with `Mock<T>`

`Mock<T>` is a **generic record** — it does NOT need `.Free`.

```pascal
uses
  Dext.Testing,   // TestFixture, Test, etc.
  Dext.Mocks;     // Mock<T>

type
  [TestFixture]
  TUserServiceTests = class
  private
    FService: TUserService;
    FMockRepo: Mock<IUserRepository>;
  public
    [Setup]
    procedure Setup;

    [Test]
    procedure GetUser_ReturnsUser_WhenExists;

    [Test]
    procedure GetUser_ReturnsNil_WhenNotFound;
  end;

procedure TUserServiceTests.Setup;
begin
  FMockRepo := Mock<IUserRepository>.Create;
  FService := TUserService.Create(FMockRepo.Instance);
end;

procedure TUserServiceTests.GetUser_ReturnsUser_WhenExists;
var
  User: TUser;
begin
  // Arrange
  User := TUser.Create;
  User.Name := 'Alice';
  FMockRepo.Setup.Returns(User).When.FindById(Arg.Any<Integer>);

  // Act
  var Result := FService.GetById(1);

  // Assert
  Should(Result).NotBeNil;
  Should(Result.Name).Be('Alice');

  // Verify
  FMockRepo.Received(Times.Once).FindById(1);
end;

procedure TUserServiceTests.GetUser_ReturnsNil_WhenNotFound;
begin
  // Arrange
  FMockRepo.Setup.Returns(nil).When.FindById(Arg.Any<Integer>);

  // Act
  var Result := FService.GetById(999);

  // Assert
  Should(Result).BeNil;
end;
```

### Mock Setup Patterns

```pascal
// Return a value
FMock.Setup.Returns(SomeValue).When.MethodName(Args);

// Return different values in sequence
FMock.Setup.Returns(User1).When.GetNext;
// On second call, returns User2, etc.

// Return nil
FMock.Setup.Returns(nil).When.MethodName(Arg.Any<T>);

// Throw exception
FMock.Setup.Throws(ENotFoundException).When.FindById(999);

// Argument matchers
Arg.Any<Integer>          // Any integer value
Arg.Is<string>('alice')   // Exact match
Arg.IsNot<string>('')     // Not equal
```

### Mock Verification

```pascal
// Verify call count
FMock.Received(Times.Once).MethodName(expectedArg);
FMock.Received(Times.Never).MethodName(Arg.Any<T>);
FMock.Received(Times.AtLeast(2)).MethodName(Arg.Any<T>);
FMock.Received(Times.Exactly(3)).MethodName(Arg.Any<T>);

// Access the interface instance
var Instance := FMock.Instance;  // IUserRepository
```

## Fluent Assertions (`Should`)

```pascal
// Equality
Should(Value).Be(Expected);
Should(Value).NotBe(Expected);

// Nil checks
Should(Obj).BeNil;
Should(Obj).NotBeNil;

// String assertions
Should(Name).StartWith('John');
Should(Name).EndWith('Doe');
Should(Name).Contain('oh');
Should(Name).StartWith('John').AndAlso.EndWith('Doe');

// Numeric comparisons
Should(Count).BeGreaterThan(0);
Should(Count).BeLessThan(100);

// Collections
Should(List).Contain(Item);
Should(List).NotContain(Item);
Should(List).ContainOnly(Item1, Item2);
Should(List).HaveCount(5);
Should(List).BeEmpty;
Should(List).NotBeEmpty;
Should(List).BeOrdered;

// Objects
Should(Obj).BeOfType<TUser>;
Should(Obj).BeAssignableTo<IPerson>;
Should(Obj1).BeEquivalentTo(Obj2);
Should(User).HaveProperty('Name').WithValue('Alice');

// Exceptions
Should.Raise<EArgumentException>(procedure begin Svc.BadCall end);
Should.RaiseAny(procedure begin Svc.BadCall end);
Should.NotRaise(procedure begin Svc.ValidCall end);

// Smart assertions (strongly typed, with Prototype)
var u := Prototype.Entity<TUser>;
Should(User).HaveValue(u.Name, 'Alice');
Should(User).HaveValue(u.Age, 30);
Users.Should.AllMatch(u.Age > 0);
```

## `Assert` (Classic Style)

The `Assert` helper from `Dext.Testing` also supports classic-style assertions:

```pascal
Assert.AreEqual(Expected, Actual);
Assert.AreNotEqual(Expected, Actual);
Assert.IsTrue(Condition);
Assert.IsFalse(Condition);
Assert.IsNil(Obj);
Assert.IsNotNil(Obj);
```

## Testing Entities with Child Collections

Entities use `OwnsObjects = False` for ORM compatibility. In unit tests (without DbContext), you must free child objects manually:

```pascal
procedure TOrderTests.Should_CalculateTotal;
var
  Order: TOrder;
  Item: TOrderItem;
begin
  Order := TOrder.Create;
  Item := TOrderItem.Create;
  try
    Item.Price := 25.00;
    Item.Quantity := 2;
    Order.Items.Add(Item);

    Order.CalculateTotal;

    Should(Order.Total).Be(50.00);
  finally
    Order.Free; // Frees Order + list, but NOT Item (OwnsObjects=False)
    Item.Free;  // REQUIRED: free child manually
  end;
end;
```

## Parametrised Tests

```pascal
[Test]
[TestCase(0, 0, 0)]
[TestCase(1, 2, 3)]
[TestCase(10, -5, 5)]
procedure Should_Add(A, B, Expected: Integer);
begin
  var Calc := TCalculator.Create;
  try
    Should(Calc.Add(A, B)).Be(Expected);
  finally
    Calc.Free;
  end;
end;
```

## Running Tests

```bash
dext test                              # Run all tests
dext test --verbose                    # Verbose output
dext test --coverage                   # With code coverage
dext test --html --output report.html  # HTML report
```

Or via Delphi IDE: Run the test console project directly.

## Integration Testing (PowerShell)

Every Web API should have a PowerShell integration test script (e.g., `Test.MyApi.ps1`):

```powershell
# Always use 127.0.0.1 (not localhost — avoids IPv6/404 issues)
$baseUrl = "http://127.0.0.1:8080"
$headers = @{
  "Accept" = "application/json"
  "Content-Type" = "application/json; charset=utf-8"
}

# Health check
$r = Invoke-RestMethod -Uri "$baseUrl/health" -Headers $headers
if ($r -ne "healthy") { throw "Health check failed" }

# Auth
$body = '{"username":"admin","password":"secret"}' | ConvertFrom-Json
$token = (Invoke-RestMethod -Method POST -Uri "$baseUrl/api/auth/login" -Body ($body | ConvertTo-Json) -Headers $headers).token

# Authenticated request
$authHeaders = $headers + @{ "Authorization" = "Bearer $token" }
$users = Invoke-RestMethod -Uri "$baseUrl/api/users" -Headers $authHeaders
```

Notes:

- Use `127.0.0.1` not `localhost` to avoid IPv6 routing issues
- Set `Accept` and `Content-Type` headers explicitly
- Enums are serialized as strings by default (`"tsOpen"`, not `1`)

## Snapshot Testing

Compare complex objects against a saved JSON baseline instead of writing dozens of `Should.Be` assertions:

```pascal
[Test]
procedure TestComplexReport;
begin
  var Result := Service.GenerateReport(123);

  // First run: creates __snapshots__/MyTests.TestComplexReport.json
  // Subsequent runs: compares against the saved file
  Result.MatchSnapshot;
end;
```

Ignore fields that change per-run (timestamps, random IDs):

```pascal
Result.MatchSnapshot(procedure(Options: TSnapshotOptions)
  begin
    Options.IgnorePaths(['$.GenerationDate', '$.UniqueIdentifier']);
  end);
```

Update snapshots after intentional logic changes:

```bash
dext test --update-snapshots
```

Snapshot files are saved in `__snapshots__/` next to the test unit.

## Mock Verification Reference

```pascal
FMock.Received(Times.Once).Method(arg);         // Exactly once
FMock.Received(Times.Never).Method(arg);        // Never
FMock.Received(Times.Exactly(3)).Method(arg);   // Exactly N times
FMock.Received(Times.AtLeast(2)).Method(arg);   // At least N
FMock.Received(Times.AtMost(5)).Method(arg);    // At most N
FMock.DidNotReceive.Delete(Arg.Any<Integer>);   // Alias for Times.Never
FMock.VerifyNoOtherCalls;                        // No other calls were made
```

Interfaces must have `{$M+}` to be mockable:

```pascal
type
  {$M+}
  IMyService = interface
    ['{...}']
    function DoWork: Boolean;
  end;
  {$M-}
```

## Full Assertion Reference

```pascal
// Equality
Value.Should.Be(42);
Value.Should.NotBe(0);
Value.Should.BeGreaterThan(10);
Value.Should.BeLessThan(100);
Value.Should.BeInRange(1, 100);

// Nil / Boolean
Obj.Should.BeNil;
Obj.Should.NotBeNil;
Flag.Should.BeTrue;
Flag.Should.BeFalse;

// String
Text.Should.Contain('ell');
Text.Should.StartWith('He');
Text.Should.EndWith('lo');
Text.Should.Match('^[A-Z]');  // Regex
Text.Should.BeEmpty;
Text.Should.HaveLength(5);

// Collections
List.Should.HaveCount(5);
List.Should.BeEmpty;
List.Should.Contain(Item);
List.Should.ContainOnly(Item1, Item2);
List.Should.BeOrdered;
var u := Prototype.Entity<TUser>;
Users.Should.AllMatch(u.Age > 0);

// Objects
Obj.Should.BeOfType<TUser>;
Obj.Should.BeAssignableTo<IPerson>;
Obj.Should.BeEquivalentTo(Other);
User.Should.HaveProperty('Name').WithValue('John');

// Exceptions
Should.Raise<EArgumentException>(procedure begin Svc.Bad end);
Should.NotRaise(procedure begin Svc.Safe end);

// Soft assertions (collect all failures)
Assert.Multiple(procedure
  begin
    User.Name.Should.Be('John');
    User.Age.Should.BeGreaterThan(18);
  end);
```

## Common Mistakes

| Wrong | Correct |
|-------|---------|
| `uses Dext.Testing` only for mocks | Also add `uses Dext.Mocks` |
| `Mock<T>.Free` | Not needed — Mock is a record |
| `.RegisterFixtures([...])` without `.Verbose` | Always include `.Verbose` |
| Not freeing child entities in tests | `Item.Free` after `Order.Free` |
| `Should(Obj).Equal(...)` | `Should(Obj).Be(...)` |

