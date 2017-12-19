# Bible Fitbit
### Development Setup
Install postgres
 ```
 brew install postgres
 ```
 If you don't have brew services installed:
 ```
 brew tap homebrew/services
 ```
 Start postgres with 
 ```
 brew services start postgresql
 ```
 Stop postres with
 ```
 brew services stop postgresql
 ```
 Then `git clone` the repository and `cd` to the project directory.

Check if you have `rvm` installed already by running `rvm -v`. 

Otherwise, install `rvm`.
```
\curl -sSL https://get.rvm.io | bash -s stable
```
`rvm` is a ruby environment manager.  It allows you to define a ruby version and a set of gems for every project you work on.

Install `ruby-2.4.2` through `rvm`.  **note**: You may running into issues with installing ruby depending on your setup.  This is especially true if you recently upgraded to El Capitan.  This usually involves owning '/usr/local' and fixing xcode.  My best advice is to just follow the warnings and error messages.

```
rvm install ruby-2.4.2
rvm use 2.4.2
```
Then then create a `gemset`.  We'll call the `gemset` "dev" but it could be any name as you see fit.
```
rvm gemset create dev
rvm gemset use dev
```
Lastly, install `bundle` and then use `bundle` to install all the `gems` in the `Gemfile`.
```
gem install bundle
bundle install
```
This should take some time because to install `rails` requires many other `gems`.

Happy developing!

**Important**: When you stop developing, exit out of this ruby environment.
```
rvm gemset use default
```
Then, previously installed gems will not work.