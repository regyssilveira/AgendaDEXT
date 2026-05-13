---
description: >-
  Especialista na camada de SSR, View Engines (Web Stencils) e integrações HTMX do
  Dext Framework.
---

<skill>

# Dext Framework View Engine & SSR

You are an expert in building server-side rendered (SSR) applications and HTMX integrations using the Dext Framework. You have deep knowledge of the Dext abstracted `IViewEngine` architecture, and its primary implementation via Web Stencils (for Delphi 12.2+).

## Core Concepts

**1. Agnostic View Engine**
Dext uses an agnostic bridge for template engines so that developers aren't locked into a single implementation. The `IViewEngine` handles template path resolution and dictionaries (`TViewData`).

**2. HTMX Native Support**
HTMX partial rendering is a first-class citizen. Dext automatically detects `HX-Request` headers to determine if it should render the "Partial" fragment or the full page layout.

**3. Flyweight Iterators (Streaming Engine)**
Whenever an ORM Query is passed to the View Engine view `Results.View('...', Db.Users.QueryAll)`, Dext wraps it in a `TStreamingViewIterator<T>`. This "flyweight" approach iterates row-by-row mapping directly to the template loop variables (e.g. `@foreach`) meaning you process **millions of records with O(1) memory**.

## Dext DSL & API

### App Configuration

The View Engine must be added in the application setup.

```pascal
procedure TStartup.ConfigureServices(const Services: TDextServices; const Configuration: IConfiguration);
begin
  Services
    .AddDbContext<TMyDbContext>(...)
    .AddWebStencils(
      procedure(Opts: TViewOptions)
      begin
        Opts.TemplateRoot := TPath.GetFullPath('wwwroot/views');
        Opts.DefaultLayout := '_Layout.html';
        
        {$IFDEF DEXT_ENABLE_WEB_STENCILS}
        TWebStencilsProcessor.Whitelist.Configure(TCustomer, '', '', False);
        {$ENDIF}
      end);
end;

procedure TStartup.Configure(const App: IWebApplication);
begin
  App.Builder
    .UseViewEngine     // Ativa a ViewEngine pre-configurada
    .UseStaticFiles('wwwroot') // Importante para recursos e css
    ...
```

### Route Handlers (Results.View)

Return `IResult` from endpoints for the view presentation.

```pascal
// Returning a simple HTML view 
Result := Results.View('index');

// Passing variables to the view
Result := Results.View('dashboard')
  .WithValue('PageTitle', 'Dashboard System')
  .WithValue('Version', '2.0.1');

// Returning an ORM Query to loop inside the HTML View
Result := Results.View<TCustomer>('customers', Db.Customers.QueryAll);

// Overriding default layout (especially for HTMX partial triggers)
// Passing empty string for Layout nullifies the master page wrapper:
Result := Results.View<TCustomer>('user_list', UserQuery).WithLayout(''); 
```

## Template Syntax (Web Stencils)

When `Dext.Web.View.WebStencils` is active, you use standard Web Stencils syntax (`@`, `@{ }`, `@if`, `@foreach`) in your `.html` files.

### 1. Variables and Loops

```html
<!-- Single Variables passed via WithValue -->
<h1>@PageTitle</h1>

<!-- Loops against the passed Model (QueryAll) -->
@foreach (var item in Model) {
  <div>
    <span>Name: @(Prop(item.Name))</span>
  </div>
}

<!-- Fallbacks and Conditionals -->
@if Model.IsEmpty {
  <p>No records found!</p>
}
```

### 2. The @Prop() Binding

Dext uses SmartProperties (`Prop<T>`, `Nullable<T>`) heavily. To read a property of an Entity in the Template correctly, use the built-in custom function `Prop()` registered automatically by the Dext framework. Use the execution block syntax `@@( )` around it in Web Stencils!

**Correct:**

```html
<td>@(Prop(item.FirstName))</td>
```

**Incorrect:**

```html
<td>@item.FirstName</td>
```

## Architectural Guidelines

1. **Avoid `ToList` with large datasets**: Never fetch memory lists if you are going to render it on screen. Provide the query directly (`Db.Users.QueryAll`) to leverage `Model.IsEmpty` and `@foreach` streaming pipeline.
2. **HTMX Navigation**: Emphasize creating rich, state-less components and utilizing HTMX verbs (`hx-get`, `hx-target`) pointing to Partial view routes.
3. **Component Reusability**: Break large layout pages into partial templates.

## Troubleshooting

- Error during loop mapping: Make sure to `Whitelist` your Classes during the `AddWebStencils` config phase.
- Missing Properties / `(record)` displayed on screen: Guarantee you are using `@(Prop(your_item.property_name))` and not accessing it plainly.
- Layout still rendering inside an `hx-target`: Verify that `HX-Request` header is reaching the Server, or manually call `.WithLayout('')`.

</skill>
