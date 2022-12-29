//
//  ReservationView.swift
//  Business-ios
//
//  Created by Eric Huang on 2022/12/5.
//

import SwiftUI

struct ReservationView: View {
    
    @AppStorage("resrve_key") private(set) var reserve_datas : [redatatype] = []
    @State private var has_data = false
    
    func removedatas(at offsets: IndexSet){
        reserve_datas.remove(atOffsets: offsets)
    }
    
    var body: some View {
        if(reserve_datas.count != 0){
            List{
                ForEach(reserve_datas, id: \.id){ reserve_data in
                    HStack{
                        Text(reserve_data.re_name).font(.system(size: 12)).padding(.leading, 5.0).frame(width:80)
                        Text(reserve_data.re_date).font(.system(size: 12)).frame(width:90)
                        Text(reserve_data.re_hour + ":" + reserve_data.re_time).font(.system(size: 12)).frame(width:40)
                        Text(reserve_data.re_email).font(.system(size: 12)).padding(.trailing, 5.0).frame(width:120)
                    }//hstack
                    
                }.onDelete(perform: removedatas)
                
            }//list
              .navigationTitle("Your Reservations").bold()
              .onAppear{
                        //reserve_datas = [redatatype]()
                        print(reserve_datas)
                        print("number of data")
                        print(reserve_datas.count)
              }//onappear
      
           
        }// if
        if(reserve_datas.count == 0){
            VStack{
                //Text("Your Reservations").bold().font(.title).frame(width:350,height: 350,alignment: .topLeading)
                //.padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 20))
                //Spacer().frame(width: 12,height: 50)
                Text("No bookings found").foregroundColor(.red)
                //Spacer().frame(width: 12,height: 350)
                
                
            }  .navigationTitle("Your Reservations").bold()
                .onAppear{
                //reserve_datas = [redatatype]()
                print(reserve_datas)
                print("number of data")
                print(reserve_datas.count)
            }//onappear
        }
    }
}

struct ReservationView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationView()
    }
}
