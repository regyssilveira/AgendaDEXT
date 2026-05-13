---
name: dext-examples
description: A comprehensive index of all official Dext framework examples. Use this as a reference to find implementations of specific architectural patterns, configurations, or features.
---

# 📦 Dext Framework Examples

The Dext framework provides several high-quality examples, categorized by utilities, features, and complete real-world scenarios. All examples are located in the `Examples\` directory of the repository.

## Business Projects & Complete Scenarios

These projects reflect modern standard practices, utilizing up-to-date fluent syntax, clean architecture, and comprehensive features. **Always use these as primary architectural references.**

| Example | Domain | What it shows |
| --- | --- | --- |
| `Web.FoodDelivery` | API | End-to-end delivery API, ORM mapping, advanced routing, background jobs, full pipeline configurations. |
| `Web.HelpDesk` | API | Ticketing system, auth, robust schema modeling, relations, generic Data APIs, Open API/Swagger. |
| `Web.SalesSystem` | API | Complex domain, transaction orchestration, layered repositories, complex ORM logic. |
| `Web.TicketSales` | API | Complete ticket/event API, concurrency limits, real-time endpoints, business rules. |
| `Web.DextStore` | API | Full e-commerce API with controller pattern, error handling, complex lists and entities (`IList<T>`). |

## Utility & Feature Demos

These examples are focused strictly on demonstrating specific framework features.

### Web & API Features

| Example | What it shows |
| --- | --- |
| `Web.MinimalAPI` | Basic routing, Dependency Injection, and modern Minimal API mapping. |
| `Web.ControllerExample` | Traditional MVC controller endpoints with full DI integration, attributes, error filters. |
| `Web.CachingDemo` | Response caching middleware, configurable duration, vary-by-query. |
| `Web.RateLimitDemo` | Fixed window rate limiting, rejection handling, rate-limit headers, partition keys. |
| `Web.SmartPropsDemo` | Smart Properties (`Prop<T>`), dynamic filtering, automatic validation, and DTO mapping. |
| `Web.SslDemo` | SSL/HTTPS with OpenSSL and Taurus TLS certificate configuration, adapter settings. |
| `Web.StreamingDemo` | Multipart file uploads (single/multiple) and direct file downloads via Chunked Stream response. |
| `Web.TUUIDBindingExample` | Route and body binding for `TUUID` types, UUID v7 generation. |
| `Web.TaskFlowAPI` | Hybrid routing mixing Minimal API and Controllers seamlessly in one application. |

### OpenAPI & Swagger

| Example | What it shows |
| --- | --- |
| `Web.SwaggerExample` | Swagger with Minimal API — fluent DSL, schema generation, endpoint tagging. |
| `Web.SwaggerControllerExample` | Swagger with Controllers — `[SwaggerOperation]`, attributes, security integration (`[SwaggerAuthorize]`). |

### Authentication & Security

| Example | What it shows |
| --- | --- |
| `Web.JwtAuthDemo` | JWT token generation, Claims manipulation, Role-based auth (`[Authorize('Admin')]`), validation. |

### Real-Time & Networking

| Example | What it shows |
| --- | --- |
| `Web.RealTimeChat` / `Web.EventHub` | Server-Sent Events (SSE), background broadcasting, real-time client notifications. |

### ORM & Databases

| Example | What it shows |
| --- | --- |
| `Orm.EntityDemo` | 18+ test suites covering CRUD, navigation properties (many-to-one, one-to-many), cascade deleting, lazy loading. |
| `Dext.Examples.ComplexQuerying` | Advanced LINQ-style queries on result sets, aggregations, filtering vectors. |

### Desktop (VCL / FMX)

| Example | What it shows |
| --- | --- |
| `Desktop.MVVM.CustomerCRUD` | Proper MVVM data binding, abstract views (`ICustomerView`), unit tests with interfaces. |

## How to Compile

Examples can be compiled either through the Delphi IDE or via command line using the MSBuild workflow:

```bash
# E.g. compiling the TicketSales API
msbuild Examples\Web.TicketSales\Web.TicketSales.dproj /p:Config=Debug /p:Platform=Win64
```
