
// ignore_for_file: unused_field, unused_element, sized_box_for_whitespace, unused_local_variable, non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freelancer/Services/global_methods.dart';
import 'package:uuid/uuid.dart';

import '../Persistent/persistent.dart';
import '../Services/global_variables.dart';
import '../Widgets/bottom_nav_bar.dart';

class UploadJobNow extends StatefulWidget {
  

  @override
  State<UploadJobNow> createState() => _UploadJobNowState();
}

class _UploadJobNowState extends State<UploadJobNow> {

  final TextEditingController _jobCategoyController = TextEditingController(text: 'Select Job category');
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController = TextEditingController();
  final TextEditingController _deadlineDateController = TextEditingController(text: 'Job Deadline Date');


  final _formFey = GlobalKey<FormState>();
  DateTime? picked;
  Timestamp? deadlineDateTimeStamp;
  bool _isLoading = false;

  @override
  void dispose()
  {
    super.dispose();
    _jobCategoyController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _deadlineDateController.dispose();
  }

  Widget _textTitles({required String label})
  {
    return Padding(

      padding: EdgeInsets.all(5.0),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textFormFields({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLenght,
  })
  {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkWell(
        onTap: (){
          fct();
        },
        child: TextFormField(
          validator: (value){
            if(value!.isEmpty)
            {
              return 'value is missing';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          style: TextStyle(
            color: Colors.white,
          ),
          maxLines: valueKey == 'Job description'? 3 : 1,
          maxLength: maxLenght,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black54,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            )
          ),

        ),
      ),
    );
  }

  _showTaskCategoriesDialogue({required Size size})
  {
    showDialog(
      context: context,
      builder: (ctx)
      {
        return AlertDialog(
          backgroundColor: Colors.black45,
          title: Text(
            'Job Category',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          content: Container(
            width: size.width*0.9,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: Persistent.JobCategoryList.length,
              itemBuilder: (context, index) 
              {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _jobCategoyController.text = Persistent.JobCategoryList[index];
                    });
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_right_alt_outlined,
                        color: Colors.grey,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            Persistent.JobCategoryList[index],
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                       ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: ()
              {
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
              child: Text('Cancel', style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                ),
                ),
            ),
          ],
        );
      }
    );
  }

  void _pickDateDialog() async
  {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        Duration(days: 0),
        ),
        lastDate: DateTime(2100), 
    );
    if(picked != null)
    {
      setState(() {
        _deadlineDateController.text = '${picked!.year} - ${picked!.month} - ${picked!.day}';
        deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(picked!.microsecondsSinceEpoch);
      });
    }
  }

  void _uploadTask() async
  {
    final jodId = Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final _uid = user!.uid;
    final isValid = _formFey.currentState!.validate();

    if(isValid)
    {
      if(_deadlineDateController.text == 'Choose job Deadline date' || _jobCategoyController.text == 'Choose job category')
      {
        GlobalMethod.showErrorDialogue(

          error: 'Please pick everything', ctx: context
          );
          return;
      }
      setState(() {
        _isLoading = true;
      });
      try
      {
        await FirebaseFirestore.instance.collection('jobs').doc(jodId).set({
          'jobId': jodId,
          'uploadedBy': _uid,
          'email': user.email,
          'jobTitle': _jobTitleController.text,
          'jobDescription': _jobDescriptionController.text,
          'deadlineDate': _deadlineDateController.text,
          'deadlineDateTimeStamp': deadlineDateTimeStamp,
          'jobCategory': _jobCategoyController.text,
          'joComments': [],
          'recruitment': true,
          'createdAt': Timestamp.now(),
          'name': name,
          'userImage': userImage,
          'location': location,
          'applicants': 0,
        });
        await Fluttertoast.showToast(
          msg: 'The task has been uploaded',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18,
        );
        _jobTitleController.clear();
        _jobDescriptionController.clear();
        setState(() {
          _jobCategoyController.text = 'Choose job category';
          _deadlineDateController.text = 'Choose job Deadline date';
        });
      }catch(error){
        {
          setState(() {
            _isLoading = false;
          });
          GlobalMethod.showErrorDialogue(error: error.toString(), ctx: context);
        }

      }
      finally
      {
        setState(() {
            _isLoading = false;
          });
      }
    }
    else
    {
      print('Its not valid');
    }
  }
 
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade300, Colors.blueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 2,),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(7.0),
            child: Card(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Please fill all fields',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Signatra',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Divider(
                      thickness: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Form(
                        key: _formFey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _textTitles(label: 'Job Category :'),
                            _textFormFields(
                              valueKey: 'JobCategory',
                              controller: _jobCategoyController,
                              enabled: false,
                              fct: (){
                                _showTaskCategoriesDialogue(size: size);
                              },
                              maxLenght: 100,
                            ),
                            _textTitles(label: 'Job title :'),
                            _textFormFields(
                              valueKey: 'Jobtitle',
                              controller:_jobTitleController,
                              enabled: true,
                              fct: () {},
                              maxLenght: 100,
                            ),
                            _textTitles(label: 'Job Description :'),
                            _textFormFields(
                              valueKey: 'JobDescription',
                              controller:_jobDescriptionController,
                              enabled: true,
                              fct: () {},
                              maxLenght: 100,
                            ),
                             _textTitles(label: 'Job Deadline Date :'),
                            _textFormFields(
                              valueKey: 'Deadline',
                              controller: _deadlineDateController,
                              enabled: false,
                              fct: () {
                                _pickDateDialog();
                              },
                              maxLenght: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: _isLoading
                        ? CircularProgressIndicator()
                        : MaterialButton(
                          onPressed: (){
                            _uploadTask();
                          },
                          color: Colors.black,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Post Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    fontFamily: 'Signatra',
                                  ),
                                ),
                                SizedBox(width: 9,),
                                Icon(
                                  Icons.upload_file,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}