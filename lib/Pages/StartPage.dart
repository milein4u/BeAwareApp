import 'LoginPage/Login.dart';
import 'SignupPage/Signup.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/flutter_flow_widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class StartPageWidget extends StatefulWidget {
  const StartPageWidget({Key? key}) : super(key: key);

  @override
  _StartPageWidgetState createState() => _StartPageWidgetState();
}

class _StartPageWidgetState extends State<StartPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Route _createRoute(String type) {
    if (type == "login") {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoginWidget(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutSine;

          var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    }
    else if (type == "registerEmail") {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SignupWidget(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutSine;

          var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    }
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          StartPageWidget(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme
            .of(context)
            .primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme
              .of(context)
              .primaryBackground,
          automaticallyImplyLeading: false,
          title: Text(
            'Welcome',
            style: FlutterFlowTheme
                .of(context)
                .title1,
          ),
          actions: [],
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 500,
                    // child: Stack(
                    //   children: [
                    //     Padding(
                    //       padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 50),
                    //       child: PageView(
                    //         controller: _model.pageViewController ??=
                    //             PageController(initialPage: 0),
                    //         scrollDirection: Axis.horizontal,
                    //         children: [
                    //           Padding(
                    //             padding: EdgeInsetsDirectional.fromSTEB(
                    //                 12, 12, 12, 12),
                    //             child: Column(
                    //               mainAxisSize: MainAxisSize.max,
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Image.asset(
                    //                   'assets/images/illi_4@2x.png',
                    //                   width: 300,
                    //                   height: 300,
                    //                   fit: BoxFit.cover,
                    //                 ),
                    //                 Padding(
                    //                   padding: EdgeInsetsDirectional.fromSTEB(
                    //                       16, 8, 16, 0),
                    //                   child: Row(
                    //                     mainAxisSize: MainAxisSize.max,
                    //                     children: [
                    //                       Text(
                    //                         'Header One',
                    //                         style: FlutterFlowTheme
                    //                             .of(context)
                    //                             .title2,
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 Padding(
                    //                   padding: EdgeInsetsDirectional.fromSTEB(
                    //                       16, 8, 16, 0),
                    //                   child: Row(
                    //                     mainAxisSize: MainAxisSize.max,
                    //                     children: [
                    //                       Expanded(
                    //                         child: Text(
                    //                           'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ',
                    //                           style: FlutterFlowTheme
                    //                               .of(context)
                    //                               .bodyText2,
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //           Padding(
                    //             padding: EdgeInsetsDirectional.fromSTEB(
                    //                 12, 12, 12, 12),
                    //             child: Column(
                    //               mainAxisSize: MainAxisSize.max,
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Image.asset(
                    //                   'assets/images/illi_3@2x.png',
                    //                   width: 300,
                    //                   height: 300,
                    //                   fit: BoxFit.cover,
                    //                 ),
                    //                 Padding(
                    //                   padding: EdgeInsetsDirectional.fromSTEB(
                    //                       16, 8, 16, 0),
                    //                   child: Row(
                    //                     mainAxisSize: MainAxisSize.max,
                    //                     children: [
                    //                       Text(
                    //                         'Header Two',
                    //                         style: FlutterFlowTheme
                    //                             .of(context)
                    //                             .title2,
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 Padding(
                    //                   padding: EdgeInsetsDirectional.fromSTEB(
                    //                       16, 8, 16, 0),
                    //                   child: Row(
                    //                     mainAxisSize: MainAxisSize.max,
                    //                     children: [
                    //                       Expanded(
                    //                         child: Text(
                    //                           'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ',
                    //                           style: FlutterFlowTheme
                    //                               .of(context)
                    //                               .bodyText2,
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //           Padding(
                    //             padding: EdgeInsetsDirectional.fromSTEB(
                    //                 12, 12, 12, 12),
                    //             child: Column(
                    //               mainAxisSize: MainAxisSize.max,
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Image.asset(
                    //                   'assets/images/illi_1@2x.png',
                    //                   width: 300,
                    //                   height: 300,
                    //                   fit: BoxFit.cover,
                    //                 ),
                    //                 Padding(
                    //                   padding: EdgeInsetsDirectional.fromSTEB(
                    //                       16, 8, 16, 0),
                    //                   child: Row(
                    //                     mainAxisSize: MainAxisSize.max,
                    //                     children: [
                    //                       Text(
                    //                         'Header Three',
                    //                         style: FlutterFlowTheme
                    //                             .of(context)
                    //                             .title2,
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 Padding(
                    //                   padding: EdgeInsetsDirectional.fromSTEB(
                    //                       16, 8, 16, 0),
                    //                   child: Row(
                    //                     mainAxisSize: MainAxisSize.max,
                    //                     children: [
                    //                       Expanded(
                    //                         child: Text(
                    //                           'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ',
                    //                           style: FlutterFlowTheme
                    //                               .of(context)
                    //                               .bodyText2,
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     Align(
                    //       alignment: AlignmentDirectional(0, 1),
                    //       child: Padding(
                    //         padding: EdgeInsetsDirectional.fromSTEB(
                    //             0, 0, 0, 10),
                    //         child: smooth_page_indicator.SmoothPageIndicator(
                    //           controller: _model.pageViewController ??=
                    //               PageController(initialPage: 0),
                    //           count: 3,
                    //           axisDirection: Axis.horizontal,
                    //           onDotClicked: (i) {
                    //             _model.pageViewController!.animateToPage(
                    //               i,
                    //               duration: Duration(milliseconds: 500),
                    //               curve: Curves.ease,
                    //             );
                    //           },
                    //           effect: smooth_page_indicator.ExpandingDotsEffect(
                    //             expansionFactor: 2,
                    //             spacing: 8,
                    //             radius: 16,
                    //             dotWidth: 16,
                    //             dotHeight: 4,
                    //             dotColor: FlutterFlowTheme
                    //                 .of(context)
                    //                 .lineColor,
                    //             activeDotColor:
                    //             FlutterFlowTheme
                    //                 .of(context)
                    //                 .primaryText,
                    //             paintStyle: PaintingStyle.fill,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 16),
                  child: FFButtonWidget(
                    onPressed: () {
                      Navigator.of(context).push(_createRoute("login"));
                    },
                    text: 'Login',
                    options: FFButtonOptions(
                      width: 300,
                      height: 50,
                      color: FlutterFlowTheme
                          .of(context)
                          .secondaryBackground,
                      textStyle: FlutterFlowTheme
                          .of(context)
                          .subtitle2
                          .override(
                        fontFamily: 'Poppins',
                        color: FlutterFlowTheme
                            .of(context)
                            .primaryText,
                      ),
                      elevation: 2,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 24),
                  child: FFButtonWidget(
                    onPressed: () {
                      Navigator.of(context).push(_createRoute("registerEmail"));
                    },
                    text: 'Register',
                    options: FFButtonOptions(
                      width: 300,
                      height: 50,
                      color: FlutterFlowTheme
                          .of(context)
                          .primaryText,
                      textStyle: FlutterFlowTheme
                          .of(context)
                          .subtitle2
                          .override(
                        fontFamily: 'Poppins',
                        color:
                        FlutterFlowTheme
                            .of(context)
                            .secondaryBackground,
                      ),
                      elevation: 2,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

