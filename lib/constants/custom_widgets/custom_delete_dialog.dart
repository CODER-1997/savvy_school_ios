import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class CustomDeleteDialog extends StatelessWidget {

    final String title;
    final VoidCallback  func;

    CustomDeleteDialog({   required this.title, required this.func});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: (){

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.white,
                insetPadding: EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),

                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12,horizontal: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  width: Get.width,
                  height: Get.height/4 ,
                  child:Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(title,
                          style: TextStyle(
                              color: CupertinoColors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold

                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [

                            ElevatedButton(

                                onPressed: (){
                                  func();

                                  Navigator.pop(context);

                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  padding:   EdgeInsets.symmetric(horizontal: Get.width/7, vertical: 14),
                                  elevation: 5,
                                ),

                                child: Text('Ha')),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  padding:   EdgeInsets.symmetric(horizontal: Get.width/7, vertical: 14),
                                  elevation: 5,
                                ),

                                onPressed: (){
                                  Navigator.pop(context);
                                }, child: Text("Yo'q")),



                          ],)
                      ],),


                  ),
                ),
              );
            },
          );
        },




        icon: Icon(Icons.delete,color: Colors.red,));
  }
}
