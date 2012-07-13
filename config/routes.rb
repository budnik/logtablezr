Showlog::Application.routes.draw do
  resources :loglines, :only => [:new, :create]
  root :to => 'loglines#new'
end
