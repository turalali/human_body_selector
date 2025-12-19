import 'package:flutter/material.dart';
import 'package:human_body_selector/svg_painter/maps.dart';
import 'package:human_body_selector/svg_painter/models/body_part.dart';
import 'package:human_body_selector/svg_painter/parser.dart';
import 'package:human_body_selector/svg_painter/size_controller.dart';
import 'package:human_body_selector/svg_painter/widgets/svg_painter.dart';

class HumanBodySelector extends StatefulWidget {
  final double? width;
  final double? height;
  final String map;
  final String? gender;
  final String? side;
  final Function(List<BodyPart> city, BodyPart? active) onChanged;
  final Function(List<BodyPart> city) onLevelChanged;
  final List<String>? initialSelectedPartsList;
  final List<String>? initialPainLevels;
  final Color? strokeColor;
  final Color? selectedColor;
  final Color? dotColor;
  final bool multiSelect;
  final bool toggle;
  final Listenable? repaint;
  final bool enabled;
  final double scale;

  const HumanBodySelector({
    Key? key,
    required this.map,
    required this.onChanged,
    required this.onLevelChanged,
    this.gender,
    this.side,
    this.width,
    this.height,
    this.strokeColor,
    this.selectedColor,
    this.dotColor,
    this.multiSelect = false,
    this.toggle = false,
    this.repaint,
    this.enabled = true,
    this.initialSelectedPartsList,
    this.initialPainLevels,
    this.scale = 1.0,
  }) : super(key: key);

  @override
  SelectableSvgState createState() => SelectableSvgState();
}

class SelectableSvgState extends State<HumanBodySelector> {
  LinearGradient sliderGradient = const LinearGradient(
    colors: <Color>[
      Color(0xff9ddefe),
      Color(0xffb3eedc),
      Color(0xffaaef9b),
      Color(0xffb4f170),
      Color(0xffc5f457),
      Color(0xffe4f05c),
      Color(0xffffe256),
      Color(0xfff5b547),
      Color(0xffed8b3d),
      Color(0xffed5d32),
      Color(0xffe72526),
    ],
  );
  List<BodyPart> _partsList = [];
  List<BodyPart> selectedPartsList = [];

  final _sizeController = SizeController.instance;
  Size? mapSize;

  BodyPart? lastSelected;

  late List<BodyPart> frontPartsList;
  late List<BodyPart> backPartsList;
  late List<BodyPart> sidePartsList;

  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.map != oldWidget.map) {
      setState(() {
        _partsList.clear();
        selectedPartsList.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if(widget.gender == 'Male'){
            frontPartsList = await Parser.instance.svgToCityList(Maps.MaleFrontBody);
            backPartsList = await Parser.instance.svgToCityList(Maps.MaleBackBody);
            sidePartsList = await Parser.instance.svgToCityList(Maps.MaleSideBody);
          }
          if(widget.gender == 'Female'){
            frontPartsList = await Parser.instance.svgToCityList(Maps.FemaleFrontBody);
            backPartsList = await Parser.instance.svgToCityList(Maps.FemaleBackBody);
            sidePartsList = await Parser.instance.svgToCityList(Maps.FemaleSideBody);
          }
          if(widget.gender == 'Child'){
            frontPartsList = await Parser.instance.svgToCityList(Maps.ChildFrontBody);
            backPartsList = await Parser.instance.svgToCityList(Maps.ChildBackBody);
            sidePartsList = await Parser.instance.svgToCityList(Maps.ChildSideBody);
          }
          await loadCityList();
          if (widget.initialSelectedPartsList != null && selectedPartsList.isEmpty) {
            for (var i = 0; i < widget.initialSelectedPartsList!.length; i++) {
              final initialPart = widget.initialSelectedPartsList![i];
              frontPartsList.forEach((element) {
                if (element.title == initialPart) {
                  if (widget.initialPainLevels != null &&
                      widget.initialPainLevels!.length > i) {
                    element.painLevel =
                        int.tryParse(widget.initialPainLevels![i]) ?? 0;
                  }
                  selectedPartsList.add(element);
                }
              });
              backPartsList.forEach((element) {
                if (element.title == initialPart) {
                  if (widget.initialPainLevels != null &&
                      widget.initialPainLevels!.length > i) {
                    element.painLevel =
                        int.tryParse(widget.initialPainLevels![i]) ?? 0;
                  }
                  selectedPartsList.add(element);
                }
              });
              sidePartsList.forEach((element) {
                if (element.title == initialPart) {
                  if (widget.initialPainLevels != null &&
                      widget.initialPainLevels!.length > i) {
                    element.painLevel =
                        int.tryParse(widget.initialPainLevels![i]) ?? 0;
                  }
                  selectedPartsList.add(element);
                }
              });
            }
          }
        });
        widget.repaint?.addListener(rePaintSvg);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //final isFemale = widget.map == Maps.HUMAN || widget.map == Maps.HUMAN1;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(widget.gender == 'Male'){
        frontPartsList = await Parser.instance.svgToCityList(Maps.MaleFrontBody);
        backPartsList = await Parser.instance.svgToCityList(Maps.MaleBackBody);
        sidePartsList = await Parser.instance.svgToCityList(Maps.MaleSideBody);
      }
      if(widget.gender == 'Female'){
        frontPartsList = await Parser.instance.svgToCityList(Maps.FemaleFrontBody);
        backPartsList = await Parser.instance.svgToCityList(Maps.FemaleBackBody);
        sidePartsList = await Parser.instance.svgToCityList(Maps.FemaleSideBody);
      }
      if(widget.gender == 'Child'){
        frontPartsList = await Parser.instance.svgToCityList(Maps.ChildFrontBody);
        backPartsList = await Parser.instance.svgToCityList(Maps.ChildBackBody);
        sidePartsList = await Parser.instance.svgToCityList(Maps.ChildSideBody);
      }
      await loadCityList();
      if (widget.initialSelectedPartsList != null && selectedPartsList.isEmpty) {
        for (var i = 0; i < widget.initialSelectedPartsList!.length; i++) {
          final initialPart = widget.initialSelectedPartsList![i];
          frontPartsList.forEach((element) {
            if (element.title == initialPart) {
              if (widget.initialPainLevels != null &&
                  widget.initialPainLevels!.length > i) {
                element.painLevel =
                    int.tryParse(widget.initialPainLevels![i]) ?? 0;
              }
              selectedPartsList.add(element);
            }
          });
          backPartsList.forEach((element) {
            if (element.title == initialPart) {
              if (widget.initialPainLevels != null &&
                  widget.initialPainLevels!.length > i) {
                element.painLevel =
                    int.tryParse(widget.initialPainLevels![i]) ?? 0;
              }
              selectedPartsList.add(element);
            }
          });
          sidePartsList.forEach((element) {
            if (element.title == initialPart) {
              if (widget.initialPainLevels != null &&
                  widget.initialPainLevels!.length > i) {
                element.painLevel =
                    int.tryParse(widget.initialPainLevels![i]) ?? 0;
              }
              selectedPartsList.add(element);
            }
          });
        }
      }
    });
    widget.repaint?.addListener(rePaintSvg);
  }

  @override
  void dispose() {
    widget.repaint?.removeListener(rePaintSvg);
    super.dispose();
  }

  rePaintSvg() {
    Future.delayed(const Duration(milliseconds: 100), loadCityList);
  }

  loadCityList() async {
    _partsList.clear();
    setState(() {
      if(widget.side == 'Front'){
        _partsList.addAll(frontPartsList);
      }
      if(widget.side == 'Back'){
        _partsList.addAll(backPartsList);
      }
      if(widget.side == 'Side'){
        _partsList.addAll(sidePartsList);
      }
      if (selectedPartsList.isNotEmpty) {
        selectedPartsList.forEach((element) {
          final rem1 = _partsList.remove(element);
          if (rem1) _partsList.add(element);
        });
      }
      mapSize = _sizeController.mapSize;
    });
  }

  void clearSelect() {
    setState(() {
      selectedPartsList.clear();
    });
  }

  void clearLastFocus() {
    setState(() {
      lastSelected = null;
    });
  }

  void updateSelection(List<BodyPart> parts) {
    setState(() {
      selectedPartsList.clear();
      selectedPartsList.addAll(parts);
    });
  }

  BodyPart? updateSelectionColor(double value) {
    if (lastSelected != null) {
      lastSelected!.painLevel = value.toInt();
      updatePart(lastSelected!);
    }
    return lastSelected;
  }

  void updatePart(BodyPart part) {
    setState(() {
      final rem1 = _partsList.remove(part);
      if (rem1) _partsList.add(part);
      final rem2 = selectedPartsList.remove(part);
      if (rem2) selectedPartsList.add(part);
    });
    widget.onLevelChanged.call(selectedPartsList);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: Stack(
        children: [
          for (var city in _partsList) _buildStackItem(city),
        ],
      ),
    );
  }

  Widget _buildStackItem(BodyPart city) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () => widget.enabled ? _toggleButton(city) : null,
      onLongPress: () => widget.enabled ? tryRemove(city) : null,
      child: CustomPaint(
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? double.infinity,
          constraints: BoxConstraints(maxWidth: widget?.width ?? 0, maxHeight: widget?.height ?? 0),
          //alignment: Alignment.center,
          // child: AbsorbPointer(
          //     absorbing: true,
          //     child: widget.child ?? SizedBox.shrink()),
        ),
        isComplex: true,
        foregroundPainter: SvgPainter(
          city: city,
          isSelected: selectedPartsList.contains(city),
          isFocused: lastSelected == city,
          dotColor: widget.dotColor,
          selectedColor:
          widget.selectedColor ?? sliderGradient.colors[city.painLevel],
          strokeColor: widget.strokeColor,
          repaint: widget.repaint,
          scale: widget.scale,
        ),
      ),
    );
  }

  void _toggleButton(BodyPart city) {
    setState(() {
      if (widget.multiSelect) {
        if (!selectedPartsList.contains(city)) {
          selectedPartsList.add(city);
          lastSelected = city;
        } else if (widget.toggle){
          city.painLevel = 0;
          selectedPartsList.remove(city);
          lastSelected = null;
        } else {
          lastSelected = city;
        }
      } else {
        selectedPartsList.clear();
        selectedPartsList.add(city);
        lastSelected = city;
      }
      widget.onChanged.call(selectedPartsList, lastSelected);
    });
  }

  tryRemove(BodyPart city) {
    if (selectedPartsList.contains(city)) {
      city.painLevel = 0;
      selectedPartsList.remove(city);
      lastSelected = null;
      widget.onChanged.call(selectedPartsList, lastSelected);
    }
  }
}
