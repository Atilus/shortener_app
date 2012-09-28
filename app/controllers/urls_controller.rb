class UrlsController < ApplicationController
	respond_to :html, :json, :xml
	before_filter :get_url_tail
	
	ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split(//)
	
	rescue_from ActiveRecord::RecordNotFound do
		flash[:notice] = " The url you entered to access does not exist"
		redirect_to :controller => "urls", :action => 'index'
	end
	
	def index
		@url = Url.new
		#@urls = Url.all
		
		#respond_with @url
	    
		#respond_with(@url, :status => :created, :location => @url) do |format|
			#format.html # index.html.erb
			#format.json { render json: @url }
		#end
	end
	
	def create
		@url = Url.new(params[:url])
		#@url.save
		
		#respond_with @url
		
		#if @url.save
			#redirect_to :controller => "urls", :action => 'index'
		#end
		
		if @url.save
			@last_url = Url.order("created_at").last
			@new_encoded = bijective_encode(@last_url.id)
			flash[:notice] = " The shortened url is: http://localhost:3000/urls/"+@new_encoded
			respond_with(@url, :status => :created, :location => @url) do |format|
				format.html { redirect_to :controller => "urls", :action => 'index' }
				format.json { render json: {:msg => " The shortened url is: http://localhost:3000/urls/"+@new_encoded} }
			end
		
		# Have to send back the errors collection if they exist for xml, json and
		# redirect back to new for html.
		else
			respond_with(@url.errors, :status => :unprocessable_entity) do |format|
				format.html { render action: "index" }
				format.json { render json: {:msg => " The url you entered is invalid!"} }
			end
		end
	end
	
	def show
		#@url = Url.find(params[:id])
		@decoded = bijective_decode(@short_url)
		@forward_url = get_url(@decoded)
		
		respond_to do |format|
	    	format.html { redirect_to @forward_url }
	    	format.json { render json: @forward_url }
		end
		
		#respond_with @url
		
		#redirect_to :controller => "urls", :action => 'index'
	end
	
	def bijective_encode(i)
		# from http://refactormycode.com/codes/125-base-62-encoding
		# with only minor modification
		return ALPHABET[0] if i == 0
		s = ''
		base = ALPHABET.length
		while i > 0
	  		s << ALPHABET[i.modulo(base)]
	  		i /= base
		end
		s.reverse
	end
	
	def bijective_decode(s)
		# based on base2dec() in Tcl translation
		# at http://rosettacode.org/wiki/Non-decimal_radices/Convert#Ruby
		i = 0
		base = ALPHABET.length
		s.each_char { |c| i = i * base + ALPHABET.index(c) }
		i
	end
	
	def get_url(index)
		return Url.find(index).url
	end
	
  	def get_url_tail
		@current_url = request.fullpath
		@short_url = @current_url.split('/').last	
	end
end

