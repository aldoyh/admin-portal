// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// Project imports:
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/ui/app/lists/selected_indicator.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class DismissibleEntity extends StatelessWidget {
  const DismissibleEntity({
    @required this.userCompany,
    @required this.entity,
    @required this.child,
    @required this.isSelected,
    this.showCheckbox = true,
    this.isDismissible = true,
  });

  final UserCompanyEntity userCompany;
  final BaseEntity entity;
  final Widget child;
  final bool isSelected;
  final bool showCheckbox;
  final bool isDismissible;

  @override
  Widget build(BuildContext context) {
    if (!userCompany.canEditEntity(entity)) {
      return child;
    }

    final localization = AppLocalization.of(context);
    final store = StoreProvider.of<AppState>(context);
    final isMultiselect =
        store.state.getListState(entity.entityType).isInMultiselect();

    final widget = SelectedIndicator(
      isSelected: isSelected &&
          showCheckbox &&
          isDismissible &&
          !isMultiselect &&
          !entity.entityType.isSetting,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 60,
        ),
        child: child,
      ),
    );

    if (!isDismissible) {
      return widget;
    }

    return Slidable(
      //actionPane: SlidableDrawerActionPane(),
      key: Key('__${entity.entityKey}_${entity.entityState}__'),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {
          //
        }),
        children: [
          if (showCheckbox)
            SlidableAction(
              onPressed: (context) =>
                  handleEntityAction(entity, EntityAction.toggleMultiselect),
              icon: Icons.check_box,
              label: localization.select,
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          SlidableAction(
            label: localization.more,
            backgroundColor: Colors.black45,
            foregroundColor: Colors.white,
            icon: Icons.more_vert,
            onPressed: (context) =>
                handleEntityAction(entity, EntityAction.more),
          ),
        ],
      ),
      /*
      secondaryActions: <Widget>[
        entity.isActive
            ? IconSlideAction(
                caption: localization.archive,
                color: Colors.orange,
                foregroundColor: Colors.white,
                icon: Icons.archive,
                onTap: () => handleEntityAction(entity, EntityAction.archive),
              )
            : IconSlideAction(
                caption: localization.restore,
                color: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.restore,
                onTap: () => handleEntityAction(entity, EntityAction.restore),
              ),
        entity.isDeleted
            ? IconSlideAction(
                caption: localization.restore,
                color: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.restore,
                onTap: () => handleEntityAction(entity, EntityAction.restore),
              )
            : IconSlideAction(
                caption: localization.delete,
                color: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                onTap: () => handleEntityAction(entity, EntityAction.delete),
              ),
      ],
      */
      child: widget,
    );
  }
}
