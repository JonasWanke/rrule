# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- Template:
## NEW · 2025-xx-xx

### ⚠️ BREAKING CHANGES
### 🎉 New Features
### ⚡ Changes
### 🐛 Bug Fixes
### ⏩ Performance Improvements
### 📜 Documentation updates
### 🏗️ Refactoring
### 📦 Build & CI
-->

## 0.2.17 · 2025-01-06

### 🎉 New Features

- add Dutch localizations (`RruleL10nNl`) ([#77](https://github.com/JonasWanke/rrule/pull/77)). Thanks to [@simonverzelen](https://github.com/simonverzelen)!

### 📦 Build & CI

- widen intl dependency to >=0.17.0 <0.21.0 ([`4740e29`](https://github.com/JonasWanke/rrule/commit/4740e29687a3e088964024f709a7977e554d06ab))

## 0.2.16 · 2024-02-07

### 🐛 Bug Fixes

- fix instance calculation with `after` and `interval > 1` ([`902b071`](https://github.com/JonasWanke/rrule/commit/902b0716086e7cf7bc4fea2f25c55ea8af41e340)), closes: [#71](https://github.com/JonasWanke/rrule/issues/71)

### 📦 Build & CI

- widen intl dependency to >=0.17.0 <0.20.0 ([`28b09bc`](https://github.com/JonasWanke/rrule/commit/28b09bc00c6c6d219a067625149882aedb0e207c))

## 0.2.15 · 2024-01-28

### 🐛 Bug Fixes

- prevent `IntegerDivisionByZeroException` with `bySetPositions` ([#67](https://github.com/JonasWanke/rrule/pull/67)), closes: [#44](https://github.com/JonasWanke/rrule/issues/44). Thanks to [@DrBu7cher](https://github.com/DrBu7cher)!
- out-of-range `bySetPositions` not handled correctly ([#69](https://github.com/JonasWanke/rrule/pull/69)), closes: [#68](https://github.com/JonasWanke/rrule/issues/68). Thanks to [@DrBu7cher](https://github.com/DrBu7cher)!

### ⏩ Performance Improvements

- when calculating instances for recurrence rules without a count, skip directly to `after` (if set) instead of calculating all instances until then ([#66](https://github.com/JonasWanke/rrule/pull/66)). Thanks to [@DrBu7cher](https://github.com/DrBu7cher)!
- when applying `bySetPositions`, reuse date lists ([`e47a0a8`](https://github.com/JonasWanke/rrule/commit/e47a0a8569547d0e0aeace8450ab4cf51254a181))

### 📦 Build & CI

- upgrade to Dart 3.0.0 ([`ce0678e`](https://github.com/JonasWanke/rrule/commit/ce0678ef5da34ed5bb041f6b77b2bf7d1b24d601))

## 0.2.14 · 2023-09-13

### 🐛 Bug Fixes

- fix string serialization with intl set to non-latin locale ([#60](https://github.com/JonasWanke/rrule/pull/60)), closes: [#59](https://github.com/JonasWanke/rrule/issues/59). Thanks to [@absar](https://github.com/absar)!
- fix recurrence calculation if start has microseconds, closes: [#62](https://github.com/JonasWanke/rrule/issues/62)

## 0.2.13 · 2023-03-22

### 🐛 Bug Fixes

- copy microseconds as well in `dateTime.copyWith(…)` ([#49](https://github.com/JonasWanke/rrule/pull/49)), closes: [#48](https://github.com/JonasWanke/rrule/issues/48). Thanks to [@plammens](https://github.com/plammens)!

### 📦 Build & CI

- widen <kbd>intl</kbd> dependency to `>=0.17.0 <0.19.0` ([`84cb5d3`](https://github.com/JonasWanke/rrule/commit/84cb5d31862a8d3152f01f35d5f6d892306483f0)), closes: [#51](https://github.com/JonasWanke/rrule/issues/51)

## 0.2.12 · 2023-03-18

### 🐛 Bug Fixes

- `RecurrenceRule`s will no longer skip the first instance if the start time contains milliseconds/microseconds ([#47](https://github.com/JonasWanke/rrule/pull/47)), closes: [#46](https://github.com/JonasWanke/rrule/issues/46). Thanks to [@plammens](https://github.com/plammens)!

## 0.2.11 · 2023-01-24

### 📦 Build & CI

- upgrade to Dart `>=2.18.0 <3.0.0` ([`160f22b`](https://github.com/JonasWanke/rrule/commit/160f22bf2da09f083f6fd99bed552fb0f549549e))
- update `intl` to `^0.18.0` ([`ed3f68d`](https://github.com/JonasWanke/rrule/commit/ed3f68d8cbada3ce18997defd223ffad96dc8877)), closes: [#45](https://github.com/JonasWanke/rrule/issues/45)

## 0.2.10 · 2022-06-17

### 🎉 New Features

- export `dateTime.copyWith(isUtc: …, …)` ([`ccc2828`](https://github.com/JonasWanke/rrule/commit/ccc28288d4a5c9a36e6eb8fa18f0d7f153902b69)), closes: [#39](https://github.com/JonasWanke/rrule/issues/39)

### 📜 Documentation updates

- clarify time zone handling in README ([`ccc2828`](https://github.com/JonasWanke/rrule/commit/ccc28288d4a5c9a36e6eb8fa18f0d7f153902b69)), closes: [#39](https://github.com/JonasWanke/rrule/issues/39)

### 📦 Build & CI

- update dependency on [<kbd>time</kbd>](https://pub.dev/packages/time) to required [^2.1.1](https://pub.dev/packages/time/changelog#211) ([`8755f27`](https://github.com/JonasWanke/rrule/commit/8755f277c23479c3d789dbc331ed84e6824f9b3d)), closes: [#37](https://github.com/JonasWanke/rrule/issues/37)

## 0.2.9 · 2022-06-08

### 🐛 Bug Fixes

- remove extensions conflicting with [<kbd>time</kbd>](https://pub.dev/packages/time) [v2.1.1](https://pub.dev/packages/time/changelog#211) ([`883523a`](https://github.com/JonasWanke/rrule/commit/883523a3ac5522d8ab0b14cb65e2ff43bcfc524e)), closes: [#36](https://github.com/JonasWanke/rrule/issues/36)

## 0.2.8 · 2022-05-05

### 🐛 Bug Fixes

- support `List<dynamic>` when decoding JSON ([#32](https://github.com/JonasWanke/rrule/pull/32)), closes: [#31](https://github.com/JonasWanke/rrule/issues/31). Thanks to [@nshoura](https://github.com/nshoura)!
- Add simple normalization before encoding to text ([`204085d`](https://github.com/JonasWanke/rrule/commit/204085d8478a13cec456759801b9869b842fcfed)), closes: [#13](https://github.com/JonasWanke/rrule/issues/13)
- Update count even if not between after and before ([`a01e5dd`](https://github.com/JonasWanke/rrule/commit/a01e5ddd2b26d3f86299d6ec8603ee1cc6c9df60)), closes: [#25](https://github.com/JonasWanke/rrule/issues/25)

## 0.2.7 · 2022-01-17

### 📜 Documentation updates

- add README section about jCal/JSON support ([`2130c72`](https://github.com/JonasWanke/rrule/commit/2130c72381732838007a24313cd2fb3f120a641d))

## 0.2.6 · 2022-01-17

### 🎉 New Features

- support jCal ([`77ca2cb`](https://github.com/JonasWanke/rrule/commit/77ca2cb808d68d98078801e90569c4230696a8fc)), closes: [#3](https://github.com/JonasWanke/rrule/issues/3)

## 0.2.5 · 2022-01-05

### 📦 Build & CI

- remove dependency on the discontinued [<kbd>supercharged_dart</kbd>](https://pub.dev/packages/supercharged_dart) ([#27](https://github.com/JonasWanke/rrule/pull/27)). Thanks to [@thomassth](https://github.com/thomassth)!

## 0.2.4 · 2022-01-04

### 🐛 Bug Fixes

- handle yearly frequency with `byMonths` and `byWeekDays` ([`8646af1`](https://github.com/JonasWanke/rrule/commit/8646af1f4f09c0a39eb73d5d5c0bc5209d8138bd)), closes: [#29](https://github.com/JonasWanke/rrule/issues/29)

## 0.2.3 · 2021-05-06

### 🎉 New Features

- support optional caching of recurrence rule iterations via `recurrenceRule.shouldCacheResults` and `.getAllInstances(…)` ([#20](https://github.com/JonasWanke/rrule/pull/20)). Thanks to [@polRk](https://github.com/polRk)!

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
