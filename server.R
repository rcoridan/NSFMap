
library(shiny)
library(ggmap)
library(mapproj)
library(RMySQL)
library(ggplot2)
library(ggthemes)


shinyServer(function(input, output) {
  
  dataInput<-reactive({
    if(input$get==0) return(NULL)
    
    isolate({
      
      con<-dbConnect(MySQL(),user="username",password="pass",dbname="nsfdata",host="hostname")
      
      qu2<-c("select State, Sum(Amount) from NSFHistory where (Title LIKE '%",input$keyword1,"%' AND Country IN ('United States')) group by State order by Sum(Amount);")
      query2<-capture.output(cat(qu2,sep=""))
      data2<-dbGetQuery(con,query2)
      if(dim(data2)[1]>0){
        colnames(data2)<-c('State','Total')
        data2$Total<-data2$Total / 1e6
        data2$State<-toupper(data2$State)
      } else
      {
        data2<-data.frame(Total=rep(0.0,50))
        data2$State <- state.abb
      }
      
      #clean up MySQL connections
      all_cons <- dbListConnections(MySQL())
      for (coni in all_cons){
        dbDisconnect(coni)
      }
      
      data2<-data2[ data2$State %in% state.abb,]
      if(dim(data2)[1]<50){
        #Patch in empty states for map
        data3<-data.frame(State=state.abb[!(state.abb %in% data2$State)])
        data3$Total=0.0
        data2<-rbind(data2,data3)
      }
      for (ii in 1:length(data2$State)){
        data2$State[ii]<-tolower(state.name[grep(data2$State[ii],state.abb)])
      }
      
      return(data2)
    })
  })
  
  output$distPlot <- renderPlot({
    if(input$get==0) return(NULL)
    kw1<-input$keyword1
    ggt<-c("NSF Keyword search of: '",kw1,"'")
    qg<-capture.output(cat(ggt,sep=""))
    
    states_map<-map_data("state")
    
    pp<-ggplot() + geom_map(data=dataInput(), aes(map_id=State, fill = Total), map = states_map,color="black")+ expand_limits(x = states_map$long, y = states_map$lat) + xlab('longitude')+ylab('latitude') + theme_few()+ theme(aspect.ratio=0.6, legend.position = "bottom", axis.ticks = element_blank(),  axis.title = element_blank(), axis.text =  element_blank()) + scale_fill_gradient(low="white", high="blue") + guides(fill = guide_colorbar(barwidth = 10, barheight = .5)) + ggtitle(qg)
    
    print(pp)
  })
  
  
})
