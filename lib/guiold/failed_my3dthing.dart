/*
import 'package:flutter/material.dart';
import 'package:vertex/controllers/vertex_controller.dart';
import 'package:vertex/vertex.dart';
import 'package:vector_math/vector_math.dart';

class My3dThing extends StatefulWidget {
  const My3dThing({Key? key}) : super(key: key);

  @override
  _My3dThingState createState() => _My3dThingState();
}

class _My3dThingState extends State<My3dThing> {
  late CameraVertexController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraVertexController(context, [
      ObjPath("oracle", "objects", "oracle.txt")
    ], [
      InstanceInfo("oracle", position: Vector3(2, -3, 3), scale: Vector3(.5, .5, .5), rotation: Quaternion(40, 40, 40, 40)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.isReady) {
      controller.init();
    }
    return ListenableBuilder(
      listenable: controller,
      builder: (context) {
        if (controller.isReady) {
          return GestureDetector(
              onPanUpdate: (details) {
                controller.updateXY(details.delta);
              },
              // child: BlendMask(
              //     blendMode: BlendMode.exclusion,
              //     child:
              //         ObjectRenderer(controller.meshInstances[0])));
              child: ObjectRenderer(controller.meshInstances[0]));
        }
        return Container();
      },
    );
  }
}
*/