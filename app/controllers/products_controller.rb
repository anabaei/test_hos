class ProductsController < ApplicationController
  
   require 'Savon'
  def index
    #@products = Product.all
    
  end

  def test
    #@products = Product.all
    if params[:search]
       @search = params[:search]
       client = Savon.client(wsdl: "http://services.dev.bcldb.com:25211/ProductService/ProductPort?wsdl") 
       results = %q(
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:prod="http://productservice.services.bcldb.com">
       <soapenv:Header/>
         <soapenv:Body>
             <prod:baseProductsByNameRequest>
             <prod:name>)+@search.to_s+%q(</prod:name>
              <prod:firstRecord>1</prod:firstRecord>
               <prod:numberOfRecords>1000</prod:numberOfRecords>
              <prod:searchLocation>ANY</prod:searchLocation>
              </prod:baseProductsByNameRequest>
           </soapenv:Body>
        </soapenv:Envelope>)
       response = client.call(:get_base_products_by_name, xml: results)
       @re =  response.to_array(:base_products_by_name_response, :base_product)
       


       render "products/index" 



      #render products_test_path ,:flash =>{ :success => "its was" } #@items = Item.search(params[:search]).order("created_at DESC")
     # @names= params[:search]



      else
            #@items = Item.all.order('created_at DESC')
    end
  end

  def ajaxcall
    #@products = Product.all
    if params[:search]
       @search = params[:search]
       client = Savon.client(wsdl: "http://services.dev.bcldb.com:25211/ProductService/ProductPort?wsdl") 
       results = %q(
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:prod="http://productservice.services.bcldb.com">
       <soapenv:Header/>
         <soapenv:Body>
             <prod:baseProductsByNameRequest>
             <prod:name>)+@search.to_s+%q(</prod:name>
              <prod:firstRecord>1</prod:firstRecord>
               <prod:numberOfRecords>1000</prod:numberOfRecords>
              <prod:searchLocation>ANY</prod:searchLocation>
              </prod:baseProductsByNameRequest>
           </soapenv:Body>
        </soapenv:Envelope>)
       response = client.call(:get_base_products_by_name, xml: results)
       @re =  response.to_array(:base_products_by_name_response,:base_product)
       @zz = "QWQW"
      respond_to do |format|
      #    #format.html {render "products/index" }
      format.js { render  :action => 'ajaxcall.js.erb', lcoals: { re: @re , amir: @zz} }
      end
   
       #render "products/index" 

       else
         
     end
  end
   



  def new
   
  end
  
  def create
    @product = Product.new(params.require(:product).permit(:sku))
    
  if @product.save
          
         @as = Product.last.sku
   # client = Savon.client(wsdl: "http://www.webservicex.net/uszip.asmx?WSDL")
 ############################# ############################# ############################# ######################################
 ################################  SETIGN UP SAVON CLIENT AND THEN MAKE A REQUEST TO INVOKE ####################################### 
 ############################# ############################# #############################  ##################################### 
     client = Savon.client(wsdl: "http://services.dev.bcldb.com:25211/ProductService/ProductPort?wsdl") 
   ## BELOW I USE SOAP UI READY CODE TO MAKE A REQUEST ##
    rest = %q(
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:prod="http://productservice.services.bcldb.com">
           <soapenv:Header/>
              <soapenv:Body>
                <prod:productBySKURequest>
                   <prod:sku>)+@as.to_s+%q(</prod:sku>
                </prod:productBySKURequest>
             </soapenv:Body>
           </soapenv:Envelope>
            )
    response = client.call(:get_product_by_sku, xml: rest)
 #############################  ENDING HITING THE SOAP  SERVICE ####################################### 
 ############################## -##############################- ######################################## 
       @res = response.to_array(:product_by_sku_response, :product, :category_manager).first
      
         if response.success?
             data = response.to_array(:product_by_sku_response, :product).first
             data_longName= response.to_array(:product_by_sku_response, :product, :upc).first
             data_country = response.to_array(:product_by_sku_response, :product, :origin, :country).first
             data_comment = response.to_array(:product_by_sku_response, :product, :comments, :comment).first
             data_container = response.to_array(:product_by_sku_response, :product, :case_configuration, :package_information, :container).first
             data_type =  response.to_array(:product_by_sku_response, :product, :vendors, :vendor)[3]
             data_manager =  response.to_array(:product_by_sku_response, :product, :category_manager).first
     #########(only for zip code call) This part is to split response into parts that we want ###### ############################## ##############################

            if data
               @name = data[:product_name]
               @brand = data[:brand]
               @long_name = data_longName[:long_name] 
               @country = data_country[:code] 
               @description = data_comment[:description] 
               @size =  data_container[:size]
               @weight = data_container[:weight]
             if data_manager.nil?
               @manager_name = "No Name"
               @manager_code =  "No Code"
              else 
               @manager_name = data_manager[:manager_name]
               @manager_code = data_manager[:manager_code]
             end
            end
      ############################## ############################## ############################## ##############################
         end
    render "products/index" 
  else
    render 'index'
    end
  end
end