//
//  ContentView.swift
//  Business-ios
//
//  Created by Eric Huang on 2022/11/24.
//

import SwiftUI
import Alamofire
import SDWebImageSwiftUI
import SwiftyJSON
import Kingfisher
import CoreLocation
import _MapKit_SwiftUI
import MapKit

struct autocompdatatype : Identifiable {
    let id = UUID()
    var name: String
}

struct ContentView: View {
    
    @State private var nodata = false
    @State private var isloading = false
    @State var keyword: String = ""
    @State var distance = 10
    @State var category = ["Default", "Arts and Entertainment", "Health and Medical", "Hotels and Travel", "Food", "Professional Services"]
    @State var selected_category = "Default"
    @State var location: String = ""
    @State private var lat = ""
    @State private var lng = ""
    @State private var auto_detect = false
    @State var datas = [datatype]()
    @State private var showsPopover = false
    @State var loadingautocomplete = false
    @State var autocomp_datas = [autocompdatatype]()
    
    var chatMessageIsValid : Bool {
       // without auto_detect
        if(!auto_detect){
            if(keyword.count == 0 || location.count == 0){
                return false
            }
            else{return true}
        }
        else{
            return !keyword.isEmpty
        }
            
    }
    var buttoncolor : Color{
        return chatMessageIsValid ? .red : .gray
    }
            
    var body: some View {
        
        NavigationView {
            Form(content: {
                Section {
                    // Text field
                    HStack {
                        Text("Keyword :   ")
                            .foregroundColor(Color.gray)
                        TextField("Required", text: $keyword)
                            .onChange(of: keyword){ keyword in
                                autocomp_datas = [autocompdatatype]()
                                loadingautocomplete = true
                                if( self.keyword.count >= 2){
                                    showsPopover = true
                                    print(self.keyword)
                                    let auto_complete_url = URL(string: "https://eric-huang-web-project.wl.r.appspot.com/autocomplete?text=\(keyword)")!
                                    AF.request(auto_complete_url).responseData { (data) in
                                        let json = try! JSON(data: data.data!)
                                        if(json["terms"].count != 0){
                                            for i in (0...(json["terms"].count-1)){
                                                autocomp_datas.append(autocompdatatype(
                                                    name: json["terms"][i]["text"].stringValue
                                                ))
                                            }//for
                                        }//if
                                        if(json["categories"].count != 0){
                                            for i in (0...(json["categories"].count-1)){
                                                autocomp_datas.append(autocompdatatype(
                                                    name: json["categories"][i]["title"].stringValue
                                                ))
                                            }//for
                                        }//if
                                        print(autocomp_datas)
                                        //print(json)
                                    }//af.request
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                                        withAnimation{
                                            loadingautocomplete = false
                                            //finish_collect = true
                                        }
                                    }//DispatchQueue.main.asyncAfter
                                  }//if
                                else {
                                    print(self.keyword.count)
                                    showsPopover = false
                                    loadingautocomplete = false
                                    autocomp_datas = [autocompdatatype]()
                                }
                            }//onchange
                            .alwaysPopover(isPresented: $showsPopover) {
                                if (loadingautocomplete){
                                    ProgressView("loading...")
                                        .scaleEffect(1)
                                        .frame(width: 400,height: 90)
                                        .foregroundColor(.gray)
                                      
                                }
                                else{
                                    ForEach(self.autocomp_datas, id: \.name){ data in
                                        Text("\(data.name)")
                                            .foregroundColor(.gray).font(.subheadline)
                                            .onTapGesture {
                                                let temp_word = String(data.name)
                                                keyword = temp_word
                                            }
                                        }.frame(width: 250,height: 30)
                                   
                                    
                                } //else
                            } //alwaysPopover
                    }
                    HStack {
                        Text("Distance :   ")
                            .foregroundColor(Color.gray)
                        TextField("Password", value: $distance, format: .number)
                    }
                    HStack {
                        Text("Category :")
                            .foregroundColor(Color.gray)
                        Picker("", selection: $selected_category) {
                            ForEach(category, id: \.self) { item in
                                Text(item)
                            }
                        }
                        .fixedSize()
                        .labelsHidden()
                        .pickerStyle(MenuPickerStyle())
                    }
                    if (!auto_detect){
                        HStack {
                            Text("Location :   ")
                                .foregroundColor(Color.gray)
                            TextField("Required", text: $location)
                        }
                    }
                    Toggle("Auto-detect my location",isOn: $auto_detect)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                        .foregroundColor(.gray)
                        .onChange(of: auto_detect) { value in
                                location = ""
                                print("auto_detect: " + String(auto_detect))
                            AF.request("https://ipinfo.io/json?token=f68843f6889c3c").responseData { (data) in
                                let json = try! JSON(data: data.data!)
                                //print(json)
                                let temp_latlng : String = json["loc"].stringValue
                                let real_latlng = temp_latlng.components(separatedBy: ",")
                                //print(real_latlng)
                                self.lat = real_latlng[0]
                                self.lng = real_latlng[1]
                                print("lat: " + lat)
                                print("lng: " + lng)
                            }
                        }
                    // Button
                    HStack {
                        Button(action:{
                            submitButton()
                        },label: {
                            Text("Submit")
                                .frame(width: 90, height: 50)
                                .background(buttoncolor)
                                .foregroundColor(Color.white)
                                .cornerRadius(12)
                                
                        }).buttonStyle(BorderlessButtonStyle())
                            .disabled(!chatMessageIsValid)

                        Button(action:{
                            clearButton()
                        },label: {
                            Text("Clear")
                                .frame(width: 90, height: 50)
                                .background(.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(12)
                        }).buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.horizontal, 70.0)
                }
                Section {
                    Text("Results")
                        .fontWeight(.bold)
                        .font(.system(size: 28))
                        .padding(.vertical, 3.0)
                    
                    if isloading{
                        ProgressView("Please wait...")
                            .scaleEffect(1)
                            .frame(width: 400,height: 90)
                            //.padding(EdgeInsets(top: 0 ,leading:100, bottom: 0, trailing: 40))
                            .foregroundColor(.gray)
                    }
                    else {
                        if nodata {
                            Text("No result available").foregroundColor(.red)
                        }
                        else {
                            List(datas) { i in
                                NavigationLink(destination: DetailCardView(detail_id: i.id)) {
                                    table (index: i.index, name: i.name, img_url: i.image_url, rating: i.rating, distance: i.distance)
                                }
                            }
                        }
                    }
                }
            })
            .navigationBarTitle("Business Search", displayMode: .automatic)
            .toolbar{
                NavigationLink(destination: ReservationView()){
                    Image(systemName: "calendar.badge.clock")
                }
            }
        }
    }
}

extension ContentView {
    
    func submitButton() {
        datas = [datatype]()
        nodata = false
        isloading = true
        
        var index = 0
        var cat = ""
        
        if selected_category == "Default" {
            cat = "all"
        }
        else if selected_category == "Arts and Entertainment" {
            cat = "arts"
        }
        else if selected_category == "Health and Medical" {
            cat = "health"
        }
        else if selected_category == "Hotels and Travel" {
            cat = "hotelstravel"
        }
        else if selected_category == "Professional Services" {
            cat = "professional"
        }
        

        // let search_url = "https://eric-huang-web-project.wl.r.appspot.com/yelp?term=\(keyword)&location=\(location)&distance=\(distance)&category=\(cat)"
        
        if (auto_detect) {
            let search_url = "https://eric-huang-web-project.wl.r.appspot.com/yelp?term=\(keyword)&location=&distance=\(distance)&category=\(cat)&lat=\(lat)&lng=\(lng)"
            AF.request(search_url).responseData { (data) in
                let json = try! JSON(data: data.data!)
                let number_data = json["businesses"].count
                if(number_data == 0){
                    print("no results")
                    nodata = true
                    isloading = false
                }
                for i in json["businesses"]{
                    index = index + 1
//                    if index == 11{
//                        break
//                    }
                    let distanceMiles = String(Int(i.1["distance"].doubleValue / 1609.3))
                    
                    self.datas.append(datatype(id: i.1["id"].stringValue, index: String(index), name: i.1["name"].stringValue, image_url: i.1["image_url"].stringValue, rating: i.1["rating"].stringValue, distance: distanceMiles))
                }
                isloading = false
            }
            print (search_url)
        }
        else {
            let search_url = "https://eric-huang-web-project.wl.r.appspot.com/yelp?term=\(keyword)&location=\(location)&distance=\(distance)&category=\(cat)"
            AF.request(search_url).responseData { (data) in
                let json = try! JSON(data: data.data!)
                let number_data = json["businesses"].count
                if(number_data == 0){
                    print("no results")
                    nodata = true
                    isloading = false
                }
                for i in json["businesses"]{
                    index = index + 1
//                    if index == 11{
//                        break
//                    }
                    let distanceMiles = String(Int(i.1["distance"].doubleValue / 1609.3))
                    
                    self.datas.append(datatype(id: i.1["id"].stringValue, index: String(index), name: i.1["name"].stringValue, image_url: i.1["image_url"].stringValue, rating: i.1["rating"].stringValue, distance: distanceMiles))
                }
                isloading = false
            }
            print (search_url)
        }
    }
    
    func clearButton() {
        keyword = ""
        distance = 10
        location = ""
        auto_detect = false
        nodata = false
    }
}

struct datatype: Identifiable {
    var id: String
    var index: String
    var name: String
    var image_url: String
    var rating: String
    var distance: String
}

struct table: View {
    var index: String
    var name: String
    var img_url: String
    var rating: String
    var distance: String
    
    var body: some View {
        HStack {
            Text(index)
                .frame(width: 30, height: 60, alignment:.center)
            AnimatedImage(url: URL(string: img_url)!)
                .resizable()
                .frame(width: 50, height: 50, alignment:.center)
                .cornerRadius(10)
            Text(name)
                .foregroundColor(.gray)
                .frame(width: 120)
            Text(rating)
                .frame(width: 30, height: 60, alignment:.center)
            Text(distance)
                .frame(width: 30, height: 60, alignment:.center)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
