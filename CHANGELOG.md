# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- Template:
## NEW · 2022-xx-xx
### ⚠️ BREAKING CHANGES
### 🎉 New Features
### ⚡ Changes
### 🐛 Bug Fixes
### 📜 Documentation updates
### 🏗️ Refactoring
### 📦 Build & CI
-->

## 0.2.10 · 2022-06-17

### 🎉 New Features
* export `dateTime.copyWith(isUtc: …, …)` ([`ccc2828`](https://github.com/JonasWanke/rrule/commit/ccc28288d4a5c9a36e6eb8fa18f0d7f153902b69)), closes: [#39](https://github.com/JonasWanke/rrule/issues/39)

### 📜 Documentation updates
* clarify time zone handling in README ([`ccc2828`](https://github.com/JonasWanke/rrule/commit/ccc28288d4a5c9a36e6eb8fa18f0d7f153902b69)), closes: [#39](https://github.com/JonasWanke/rrule/issues/39)

### 📦 Build & CI
* update dependency on [<kbd>time</kbd>](https://pub.dev/packages/time) to required [^2.1.1](https://pub.dev/packages/time/changelog#211) ([`8755f27`](https://github.com/JonasWanke/rrule/commit/8755f277c23479c3d789dbc331ed84e6824f9b3d)), closes: [#37](https://github.com/JonasWanke/rrule/issues/37)

## 0.2.9 · 2022-06-08

### 🐛 Bug Fixes
* remove extensions conflicting with [<kbd>time</kbd>](https://pub.dev/packages/time) [v2.1.1](https://pub.dev/packages/time/changelog#211) ([`883523a`](https://github.com/JonasWanke/rrule/commit/883523a3ac5522d8ab0b14cb65e2ff43bcfc524e)), closes: [#36](https://github.com/JonasWanke/rrule/issues/36)

## 0.2.8 · 2022-05-05

### 🐛 Bug Fixes
* support `List<dynamic>` when decoding JSON ([#32](https://github.com/JonasWanke/rrule/pull/32)), closes: [#31](https://github.com/JonasWanke/rrule/issues/31). Thanks to [@nshoura](https://github.com/nshoura)!
* Add simple normalization before encoding to text ([`204085d`](https://github.com/JonasWanke/rrule/commit/204085d8478a13cec456759801b9869b842fcfed)), closes: [#13](https://github.com/JonasWanke/rrule/issues/13)
* Update count even if not between after and before ([`a01e5dd`](https://github.com/JonasWanke/rrule/commit/a01e5ddd2b26d3f86299d6ec8603ee1cc6c9df60)), closes: [#25](https://github.com/JonasWanke/rrule/issues/25)

## 0.2.7 · 2022-01-17

### 📜 Documentation updates
* add README section about jCal/JSON support ([`2130c72`](https://github.com/JonasWanke/rrule/commit/2130c72381732838007a24313cd2fb3f120a641d))

## 0.2.6 · 2022-01-17

### 🎉 New Features
* support jCal ([`77ca2cb`](https://github.com/JonasWanke/rrule/commit/77ca2cb808d68d98078801e90569c4230696a8fc)), closes: [#3](https://github.com/JonasWanke/rrule/issues/3)

## 0.2.5 · 2022-01-05

### 📦 Build & CI
* remove dependency on the discontinued [<kbd>supercharged_dart</kbd>](https://pub.dev/packages/supercharged_dart) ([#27](https://github.com/JonasWanke/rrule/pull/27)). Thanks to [@thomassth](https://github.com/thomassth)!

## 0.2.4 · 2022-01-04

### 🐛 Bug Fixes
* handle yearly frequency with `byMonths` and `byWeekDays` ([`8646af1`](https://github.com/JonasWanke/rrule/commit/8646af1f4f09c0a39eb73d5d5c0bc5209d8138bd)), closes: [#29](https://github.com/JonasWanke/rrule/issues/29)

## 0.2.3 · 2021-05-06

### 🎉 New Features
* support optional caching of recurrence rule iterations via `recurrenceRule.shouldCacheResults` and `.getAllInstances(…)` ([#20](https://github.com/JonasWanke/rrule/pull/20)). Thanks to [@polRk](https://github.com/polRk)!

## 0.2.2 · 2021-04-28

### 🎉 New Features
- feat: expose `RecurrenceRuleToStringOptions` directly in `recurrenceRule.toString(…)` ([`c5291d1`](https://github.com/JonasWanke/rrule/commit/c5291d165b84f6354550cf919fe379f40b3c3d3b)), improves: [#21](https://github.com/JonasWanke/rrule/issues/21)

## 0.2.1 · 2021-04-26

### 🐛 Bug Fixes
- disallow invalid recurrence rule field combinations ([`2707922`](https://github.com/JonasWanke/rrule/commit/2707922bb6b8860c5118be8c896f680e075dd2e5)), closes: [#19](https://github.com/JonasWanke/rrule/issues/19)

## 0.2.0 · 2021-03-26

### ⚠️ BREAKING CHANGES

- migrate to null-safety
- Dates and DateTimes no longer use [<kbd>time_machine</kbd>](https://pub.dev/packages/time_machine), but `DateTime` instead.
  All provided `DateTime`s must be in UTC.
- remove `recurrenceRule.weekStart` (Monday is now used everywhere) and `recurrenceRule.weekYearRule`
- remove `RecurrenceSet` as its logic isn't implemented yet


## 0.1.3 · 2021-01-27

### 🎉 New Features
- add `clearUntil`/`clearCount`/`clearInterval` to `recurrenceRule.copyWith(…)`, closes: [#17](https://github.com/JonasWanke/rrule/issues/17)


## 0.1.2 · 2020-11-24

### 🐛 Bug Fixes
- hide new conflicting extension from [<kbd>collection</kbd>](https://pub.dev/packages/collection), closes: [#14](https://github.com/JonasWanke/rrule/issues/14)

### 🎉 New Features
- add `RecurrenceRule.copyWith(…)`


## 0.1.1 · 2020-07-09

### 🎉 New Features
- add `RecurrenceRule.toText()` for conversion to a human-readable string ([#7](https://github.com/JonasWanke/rrule/pull/7)), closes: [#5](https://github.com/JonasWanke/rrule/issues/5)


## 0.1.0 · 2020-05-26

Initial release 🎉
