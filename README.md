NAME
====

Tron - Tron fights for the users!

SYNOPSIS
========

A web application and middleware for managing and providing user
authenication, permission and identification.
[Tron fights for the users!](http://www.youtube.com/watch?v=DkTb7Pe2MtY)

    # in a sinatra application
    require 'sinatra'
    require 'sinatra/tron'

    get '/' do
      'This is the front door. <a href="/admin">Enter</a>.'
    end

    get '/admin' do
      authenticate!
      "You're inside!"
    end

    # in a modular sinatra application
    require 'sinatra/base'
    require 'sinatra/tron'

    class Doorway < Sinatra::Base
      register Sinatra::Tron

      get '/' do
        'This is the front door. <a href="/admin">Enter</a>.'
      end
  
      get '/admin' do
        authenticate!
        "You're inside!"
      end
    end

AUTHOR
======

Delon Newman
