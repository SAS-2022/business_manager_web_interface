import 'package:flutter/material.dart';
import '../../theme/responsive_utils.dart';

class AnimatedRadioButton extends StatefulWidget {
  const AnimatedRadioButton(
      {super.key,
      this.quantity,
      this.titles,
      required this.onSelected,
      this.initialSelected});
  final int? quantity;
  final List<String>? titles;
  final Function onSelected;
  final int? initialSelected;

  @override
  State<AnimatedRadioButton> createState() => _AnimatedRadioButtonState();
}

class _AnimatedRadioButtonState extends State<AnimatedRadioButton> {
  //Initials
  ResponsiveUtils? responsive;
  //Variables
  int _selectedValue = 0;

  @override
  void didChangeDependencies() {
    responsive = ResponsiveUtils(context);
    _selectedValue = widget.initialSelected ?? 0;
    super.didChangeDependencies();
  }

  void onSelected(int value) {
    setState(() {
      _selectedValue = value;
    });

    widget.onSelected(_selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: widget.quantity,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              onSelected(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: responsive!.responsivePaddingVer,
              padding: responsive!.responsivePaddingS,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedValue == index
                      ? Theme.of(context).colorScheme.onPrimaryFixed
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedValue == index
                            ? Theme.of(context).colorScheme.onPrimaryFixed
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _selectedValue == index ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.onPrimaryFixed,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: responsive!.scaleWidth(12)),
                  Text(
                    widget.titles![index],
                    style: TextStyle(
                      fontSize: responsive!.scaleFont(14),
                      color: _selectedValue == index
                          ? Theme.of(context).colorScheme.onPrimaryFixed
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
