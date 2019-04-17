# VstsTools

A PowerShell module providing a wrapper for the Azure DevOps API.  The aim of this project is to provide a framework to quickly develop functions that can call the Azure DevOps API and parse the returned JSON into useful PowerShell objects.

## Installation

- install published version (ie widget, module from PowerShell gallery)
- install\set up locally for testing\developing

## Usage

- basic usage instructions

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Depedencies

- tools and frameworks required to develop / run this

## Solution Structure

* Classes - Holds the definitions for the custom classes used in this module.  The classes are a representation of the data returned by the Azure DevOps API but only contain a subset of the data.
* Functions\Private - Contains functions that are called by other cmdlets within this module but are not exported.
* Functions\Public - Contains functions that are called by other cmdlets within this module but are exported.

## Deployment Process

- outline of build and release

## Licence

[GPL-3.0](/LICENSE)

