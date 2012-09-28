class UrlsController < ApplicationController
	respond_to :html, :json, :xml
	before_filter :get_url_tail
	
	ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split(//)
	
	rescue_from ActiveRecord::RecordNotFound do
		flash[:notice] = " The url you entered to access does not exist"
		redirect_to :controller => "urls", :action => 'index'
	end
	
	#Main
	def index
		@url = Url.new
	end
	
	#Creates a new url given the correct parameters
	def create
		@url = Url.new(params[:url])
		
		if @url.save
			@last_url = Url.order("created_at").last
			@new_encoded = bijective_encode(@last_url.id)
			flash[:notice] = " The shortened url is: http://shortapp.herokuapp.com/"+@new_encoded
			respond_with(@url, :status => :created, :location => @url) do |format|
				format.html { redirect_to root_path }
				format.json { render json: {:msg => " The shortened url is: http://shortapp.herokuapp.com/"+@new_encoded} }
			end
		else
			respond_with(@url.errors, :status => :unprocessable_entity) do |format|
				format.html { render action: "index" }
				format.json { render json: {:msg => " The url you entered is invalid!"} }
			end
		end
	end
	
	#Displays individual short urls
	def show
		@decoded = bijective_decode(@short_url)
		@forward_url = get_url(@decoded)
		
		respond_to do |format|
	    	format.html { redirect_to @forward_url }
	    	format.json { render json: @forward_url }
		end
	end
	
	#Encodes a given original url
	#Based on http://refactormycode.com/codes/125-base-62-encoding
	def bijective_encode(i)
		return ALPHABET[0] if i == 0
		s = ''
		base = ALPHABET.length
		while i > 0
	  		s << ALPHABET[i.modulo(base)]
	  		i /= base
		end
		s.reverse
	end
	
	#Decodes a short url and returns the original one
	#Based on http://rosettacode.org/wiki/Non-decimal_radices/Convert#Ruby
	def bijective_decode(s)
		i = 0
		base = ALPHABET.length
		s.each_char { |c| i = i * base + ALPHABET.index(c) }
		i
	end
	
	#Returns an url given its id
	def get_url(index)
		return Url.find(index).url
	end
	
  	#Gets the last part(short url) of a given url 
	def get_url_tail
		@current_url = request.fullpath
		@short_url = @current_url.split('/').last	
	end
end

