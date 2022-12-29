//
//  DetailCardView.swift
//  Business-ios
//
//  Created by Eric Huang on 2022/11/29.
//

import SwiftUI
import Alamofire
import SDWebImageSwiftUI
import SwiftyJSON
import Kingfisher
import CoreLocation
import _MapKit_SwiftUI
import MapKit


struct DetailCardView: View {
    
    let detail_id: String
    
    init(detail_id: String) {
        self.detail_id = detail_id
    }
    
    var body: some View {
        TabView {
            Detail(detail_id: detail_id)
                .tabItem {
                    Label("Business Detail", systemImage: "text.bubble.fill")
                }
            PinAnnotationMapView(detail_id: detail_id)
                .tabItem {
                    Label("Map Location", systemImage: "location.fill")
                }
            Review(detail_id: detail_id)
                .tabItem {
                    Label("Reviews", systemImage: "message.fill")
                }
        }
    }
}

struct Detail: View {
    
    var detail_id: String
    @ObservedObject var detailInfo = observerDetail()
    
    @State private var isShowing_cancel = false
    //儲存資料
    @AppStorage("resrve_key") private(set) var reserve_datas : [redatatype] = []
    @State private var isBooked = false
    @State private var place_name = ""
    @State private var showingSheet = false
    // @State private var status_color: Color = Color.green

    
    init(detail_id: String, detailInfo: observerDetail = observerDetail()) {
        self.detail_id = detail_id
        self.detailInfo = detailInfo
        detailInfo.detailApi(detail_id: self.detail_id)
    }
    
    var body: some View {
        VStack {
            ForEach(detailInfo.detaildata) {i in
                Text(i.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10.0)
                Spacer().frame(height: 30)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Address")
                            .fontWeight(.bold)
                            .frame(width:175 ,alignment: .topLeading)
                        Text(i.address)
                            .foregroundColor(Color.gray)
                            .frame(width: 175, alignment: .topLeading)
                    }
                    VStack(alignment: .trailing) {
                        Text("Category")
                            .fontWeight(.bold)
                            .frame(width:175 ,alignment: .trailing)
                        Text(i.category)
                            .foregroundColor(Color.gray)
                            .frame(width: 175, alignment: .trailing)
                    }
                }
                Spacer().frame(height: 30)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Phone")
                            .fontWeight(.bold)
                            .frame(width:175 ,alignment: .topLeading)

                        Text(i.phone)
                            .foregroundColor(Color.gray)
                            .frame(width:175 ,alignment: .topLeading)
                    }
                    VStack(alignment: .trailing) {
                        Text("Price Range")
                            .fontWeight(.bold)
                            .frame(width:175 ,alignment: .trailing)
                        Text(i.price)
                            .foregroundColor(Color.gray)
                            .frame(width:175 ,alignment: .trailing)
                    }
                }
                Spacer().frame(height: 30)
                HStack {
                    if (i.status == "Closed") {
                        VStack(alignment: .leading) {
                            Text("Status")
                                .fontWeight(.bold)
                                .frame(width:175 ,alignment: .topLeading)
                            Text(i.status)
                                .foregroundColor(Color.red)
                                .frame(width:175 ,alignment: .topLeading)
                        }
                    }
                    else {
                        VStack(alignment: .leading) {
                            Text("Status")
                                .fontWeight(.bold)
                                .frame(width:175 ,alignment: .topLeading)
                            Text(i.status)
                                .foregroundColor(Color.green)
                                .frame(width:175 ,alignment: .topLeading)
                        }
                    }
                    VStack(alignment: .trailing) {
                        Text("Visit Yelp for more")
                            .fontWeight(.bold)
                            .frame(width:175 ,alignment: .trailing)
                        Link("Business Link", destination: URL(string: "\(i.link)")!)
                    }
                }
                Spacer().frame(height: 20)
                VStack {
                    if (!isBooked){
                        HStack{
                            Button(action: {
                                showingSheet.toggle()
                                //isBooked = true
                                place_name = i.name
                                for reserve_data in reserve_datas {
                                    print(reserve_data.re_name)
                                    if(self.place_name == reserve_data.re_name){
                                        print("it is been booked")
                                        isBooked = true
                                        print(isBooked)
                                    }
                                        
                                }//for
                            }, label: {
                                Text("Reserve Now")
                                    .font(.subheadline)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                    .frame(width: 200)
                                
                            })//button
                            .sheet(isPresented: $showingSheet) {
                                ReservationSheetView(place_name: self.$place_name, isBooked: self.$isBooked)
                            }//sheet
                        }//hstack
                    }//if isBooked
                    else{
                        HStack{
                            Button(action: {
                                // toast for cancel
                                isShowing_cancel = true
                                // delete reserve_dates
                                //var delete_index :int
                                var i = 0
                                for reserve_data in reserve_datas {
                                    if(self.place_name == reserve_data.re_name){
                                        reserve_datas.remove(at: i)
                                    }
                                    i = i+1
                                }//for
                                isBooked = false
                                print("reight now reserve_datas")
                                print(reserve_datas)
                            }, label: {
                                Text("Cancel Reservation ")
                                    .font(.subheadline)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                    .frame(width: 200)
                                
                            })//button
                        }//hstack
                        
                    }//else
                    
                    HStack {
                        Text("Share on: ")
                            .fontWeight(.bold)
                        Link(destination: URL(string: "https://www.facebook.com/share.php?u=\(i.link)")!) {
                            Image("facebook-icon")
                                .resizable()
                                .frame(width: 35, height: 35)
                        }.buttonStyle(BorderlessButtonStyle())
                        Link(destination: URL(string: "https://twitter.com/intent/tweet?url=\(i.link)")!) {
                            Image("twitter-icon")
                                .resizable()
                                .frame(width: 35, height: 35)
                        }.buttonStyle(BorderlessButtonStyle())
                    }.padding(.top)
                }
                TabView {
                    KFImage(URL(string: "\(i.image_url1)"))
                        .resizable()
                        .frame(width: 280, height: 200)
                    KFImage(URL(string: "\(i.image_url2)"))
                        .resizable()
                        .frame(width: 280, height: 200)
                    KFImage(URL(string: "\(i.image_url3)"))
                        .resizable()
                        .frame(width: 280, height: 200)
                }
                .padding(.top)
                .tabViewStyle(PageTabViewStyle())
                    .frame(width: 280, height: 200)
            }
        }
    }
}

class observerDetail: ObservableObject {

    @Published var detaildata = [detaildatatype]()

    func detailApi(detail_id: String) {
        
        self.detaildata = []
        
        // let search_url = "https://eric-huang-web-project.wl.r.appspot.com/detail?id=\(detail_id)"
        let search_url = "https://eric-huang-web-project.wl.r.appspot.com/detail?id=\(detail_id)"
        AF.request(search_url)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { data in
                switch data.result {
                case .success:
                    let json = try! JSON(data: data.data!)
                    print("get detail api")
                    var cat_array: [String] = []
                    for i in json["categories"] {
                        cat_array.append(i.1["title"].stringValue)
                    }
                    let new_cat = cat_array.joined(separator: " | ")
                    var status = ""
                    if json["hours"][0]["is_open_now"].stringValue == "false" {
                        status = "Closed"
                    }
                    if json["hours"][0]["is_open_now"].stringValue == "true" {
                        status = "Open now"
                    }
                    self.detaildata.append(detaildatatype(name: json["name"].stringValue, address: json["location"]["display_address"][0].stringValue, category: new_cat, phone: json["display_phone"].stringValue, price: json["price"].stringValue, status: status, link: json["url"].stringValue, image_url1: json["photos"][0].stringValue, image_url2: json["photos"][1].stringValue, image_url3: json["photos"][2].stringValue))
                    print(json["name"].stringValue)
                    if self.detaildata.count == 0 {
                        print("no result")
                    }
                case let .failure(error):
                    print("detail api fail")
                    print(error)
                }
        }
    }
}

struct detaildatatype: Identifiable {
    var id = UUID()
    var name: String
    var address: String
    var category: String
    var phone: String
    var price: String
    var status: String
    var link: String
    var image_url1: String
    var image_url2: String
    var image_url3: String
}

// MAP
struct PinAnnotationMapView: View {
    let detail_id: String
    @State var lat = 0.0
    @State var long = 0.0
    
    func mapApi() {
        let search_url = "https://eric-huang-web-project.wl.r.appspot.com/detail?id=\(detail_id)"
        AF.request(search_url)
            .responseData { data in
                let json = try! JSON(data: data.data!)
                lat = Double(json["coordinates"]["latitude"].stringValue) ?? 0.0
                long = Double(json["coordinates"]["longitude"].stringValue) ?? 0.0
            }
    }
    
    var body: some View {
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        let place = IdentifiablePlace(lat: lat, long: long)
        
        Map(coordinateRegion: .constant(region), annotationItems: [place]) { place in
            MapMarker(coordinate: place.location)
        }.onAppear(perform: {mapApi()})
    }
}

struct IdentifiablePlace: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
    init(id: UUID = UUID(), lat: Double, long: Double) {
        self.id = id
        self.location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
    }
}

// REVIEW
struct Review: View {
    
    let detail_id: String
    @ObservedObject var reviewInfo = observerReview()
    
    init(detail_id: String, reviewInfo: observerReview = observerReview()) {
        self.detail_id = detail_id
        self.reviewInfo = reviewInfo
        reviewInfo.reviewApi(detail_id: self.detail_id)
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(reviewInfo.reviewdata) { i in
                    VStack {
                        HStack {
                            Text(i.name)
                                .fontWeight(.bold)
                                .padding(.trailing, 90.0)
                            Text(i.rating + "/5")
                                .fontWeight(.bold)
                                .padding(.leading, 90.0)
                        }
                        .frame(width: 320.0)

                        .padding(.all)
                        Text(i.text)
                            .foregroundColor(Color.gray)
                            .padding(.horizontal)
                            .frame(width: 320.0)
                        Text(i.date)
                            .padding(.vertical)
                    }
                }
            }
        }
    }
}

class observerReview: ObservableObject {

    @Published var reviewdata = [reviewdatatype]()

    func reviewApi(detail_id: String) {
        
        self.reviewdata = []
        
        // let search_url = "https://eric-huang-web-project.wl.r.appspot.com/review?id=\(detail_id)"
        let search_url = "https://eric-huang-web-project.wl.r.appspot.com/review?id=\(detail_id)"
        AF.request(search_url)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { data in
                switch data.result {
                case .success:
                    let json = try! JSON(data: data.data!)
                    print("get review api")
                    for i in json["reviews"] {
                        let date_slice = i.1["time_created"].stringValue.prefix(10)
                        self.reviewdata.append(reviewdatatype(name: i.1["user"]["name"].stringValue, rating: i.1["rating"].stringValue, text: i.1["text"].stringValue, date: String(date_slice)))
                    }
                    if self.reviewdata.count == 0 {
                        print("no review")
                    }
                case let .failure(error):
                    print("review api fail")
                    print(error)
                }
        }
    }
}

struct reviewdatatype: Identifiable {
    var id = UUID()
    var name: String
    var rating: String
    var text: String
    var date: String
}



// reserve
struct redatatype: Identifiable,Codable {
    var id = UUID()
    var re_name : String
    var re_email :String
    var re_date: String
    var re_hour: String
    var re_time: String
}

extension Array: RawRepresentable where Element: Codable {
public init?(rawValue: String) {
    guard let data = rawValue.data(using: .utf8),
          let result = try? JSONDecoder().decode([Element].self, from: data)
    else {
        return nil
    }
    self = result
}

public var rawValue: String {
    guard let data = try? JSONEncoder().encode(self),
          let result = String(data: data, encoding: .utf8)
    else {
        return "[]"
    }
    return result
    }
}

struct confirmsheet :View{
    @Environment(\.dismiss) var dismiss

    @Binding var place_name : String
    init(place_name: Binding<String>){
        self._place_name = place_name
    }
    var body: some View {
        VStack{
            VStack{
                Text("Congratulations!").foregroundColor(.white)
                Text(" ")
                Text("You have successfully made an reservation at ").foregroundColor(.white)
                Text("\(self.place_name)").foregroundColor(.white)
            }.frame(height:600, alignment: .center)
            
                Button(action: {
                    dismiss()
                    
                }, label: {
                    Text("Done")
                        .font(.subheadline)
                        .cornerRadius(15)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.green)
                        .cornerRadius(15)
                        .frame(width:400,height: 80,alignment: .center)
                    
                })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
            
        
    }
    
    
}

struct cancelModifier: ViewModifier{
    @Binding var isShowing_cancel: Bool
    let duration: TimeInterval
    func body(content: Content) -> some View {
        ZStack{
            content
            if isShowing_cancel{
                VStack{
                    Spacer()
                    HStack{
                        Text("Your reservation is cancelled.").padding().font(.subheadline)
                    }
                    .frame( minWidth: 0, maxWidth:.infinity,minHeight: 60)
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(15)
                    .padding()
                    
                }
                .padding()
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() +
                                                  duration){
                                                 withAnimation{ isShowing_cancel = false}
                    }
                }
            }
            
        }
    }
}

struct ToastModifier: ViewModifier{
    @Binding var isShowing: Bool
    let duration: TimeInterval
    func body(content: Content) -> some View {
        ZStack{
            content
            if isShowing{
                VStack{
                    Spacer()
                    HStack{
                        Text("Please enter a valid email.").padding().font(.subheadline)
                    }
                    .frame( minWidth: 0, maxWidth:.infinity,minHeight: 60)
                    .background(Color.gray)
                    .cornerRadius(15)
                    .padding()
                    
                }
                .padding()
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() +
                                                  duration){
                                                 withAnimation{ isShowing = false}
                    }
                }
            }
            
        }
    }
}
extension View{
    func cancel(isShowing_cancel: Binding<Bool>, durnation: TimeInterval = 2 ) -> some
    View{
        modifier(cancelModifier(isShowing_cancel: isShowing_cancel, duration: durnation))
    }
    func toast(isShowing: Binding<Bool>, durnation: TimeInterval = 2 ) -> some
    View{
        modifier(ToastModifier(isShowing: isShowing, duration: durnation))
    }
}
extension String {
    subscript(idx: Int) -> String {
        String(self[index(startIndex, offsetBy: idx)])
    }
}



// Reservation Form(Sheet)
struct ReservationSheetView: View {
    
    @AppStorage("resrve_key") private(set) var reserve_datas : [redatatype] = []
    
    @Environment(\.dismiss) var dismiss
    @State private var isSubmitted = false
    @State private var closefirstsheet = false
    @State private var showingconfirmSheet = false
    // value pass into
    @Binding var place_name : String
    @Binding var isBooked : Bool
    @State private var email = ""
    @State private var select_date = Date()
    @State private var select_hour = "10"
    @State private var select_min = "00"
    var hourOptions = ["10","11","12","13","14","15","16","17", "18", "19", "20", "21", "22"]
    var minOptions = ["00","15","30","45"]
    @State private var emailexist = false
    // toast for email valiation
    @State private var isShowingToast = false

    init(place_name: Binding<String>, isBooked: Binding<Bool>){
        self._place_name = place_name
        self._isBooked = isBooked
    }
    

    var body: some View {
        ZStack{
            Form{
                Section{
                    Text("Reservation Form").font(.title).bold().padding(EdgeInsets(top: 0 ,leading:40, bottom: 0, trailing: 40))
                }
                Section{
                    Text(self.place_name).font(.title).bold().padding(EdgeInsets(top: 0 ,leading:40, bottom: 0, trailing: 40))
                }
                Section{
                    HStack{
                        Text("Email :").foregroundColor(.gray).padding(EdgeInsets(top: 0 ,leading:-12, bottom: 0, trailing: 0))
                        TextField("", text: $email)
                    }
                    .padding(.vertical, 10.0)
                    HStack{
                        Text("Date/Time :").foregroundColor(.gray)
                        DatePicker("", selection: $select_date, in: Date()..., displayedComponents: .date)
                        Picker("", selection: $select_hour){
                            ForEach(hourOptions, id:\.self){ item in
                                Text(item)
                            }
                        }.labelsHidden()
                        Text(":")
                        Picker("", selection: $select_min){
                            ForEach(minOptions, id:\.self){ item in
                                Text(item)
                            }
                        }.labelsHidden().padding(EdgeInsets(top: 0 ,leading:-12, bottom: 0, trailing: 0))
                    }
                    .padding(.vertical, 5.0)
                    //
                    Button(action: {
                        // no email
                        var email_valid = false
                        if (email.count > 0){
                            for i in (0...(email.count-1)){
                                if (email[i] == "@"){
                                    email_valid = true
                                }
                            }//for
                        }
                        if (email.count==0){
                            //emailexist = false
                            isShowingToast = true
                            //toast(isShowing: $isShowingToast)
                            //closefirstsheet = true
                        }
                        else if (!email_valid){
                            isShowingToast = true
                        }
                        else{
                            //emailexist = false
                            //self.isBooked = true
                            isSubmitted = true
                            isShowingToast = false
                            //showingconfirmSheet.toggle()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let real_re_date = dateFormatter.string(from: self.select_date)
                            self.reserve_datas.append(redatatype(
                                re_name: self.place_name,
                                re_email: self.email,
                                re_date: real_re_date,
                                re_hour: self.select_hour,
                                re_time: self.select_min))
                            print(self.reserve_datas)
                        }
                    }, label: {
                        Text("Submit")
                            .font(.subheadline)
                            .cornerRadius(15)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .frame(width:400,height: 80,alignment: .center)
                    })
                    
                    .sheet(isPresented: $showingconfirmSheet) {
                        confirmsheet(place_name: self.$place_name)
                    }

                    //
                }
            }.toast(isShowing: $isShowingToast)//form
                //.onAppear{}
                //.onDisappear{if closefirstsheet{dismiss()}}
          
        }
        if isSubmitted{
            HStack{
                Spacer()
                VStack{
                    VStack{
                        Text("Congratulations!").foregroundColor(.white)
                        Text(" ")
                        Text("You have successfully made an reservation at ").foregroundColor(.white)
                        Text("\(self.place_name)").foregroundColor(.white)
                    }.frame(height:600, alignment: .center)
                        Spacer()
                        Button(action: {
                            dismiss()
                            self.isBooked = true
                            
                        }, label: {
                            Text("Done").frame(width:300,height: 30,alignment: .center)
                                .font(.subheadline)
                                .cornerRadius(15)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.green)
                                .cornerRadius(15)
                                //.frame(width:600,height: 80,alignment: .center)
                            
                        }).frame(width:600,height: 80,alignment: .center)
                    
                  
                }
                .background(Color.green)
            }.frame(height: 800)
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        withAnimation{
                            dismiss()
                            self.isBooked = true
                        }//withAnimation
                    }//DispatchQueue.main.asyncAfter
                    
                }// onAppear

        }//isSubmitted
    }//bodyview
}

struct DetailCardView_Previews: PreviewProvider {
    static var previews: some View {
        DetailCardView(detail_id: "us0WnDOySVXXXwCqs0AaCw")
    }
}
