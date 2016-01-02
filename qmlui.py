import sys

from PyQt5.QtCore import pyqtProperty, QCoreApplication, QObject, QUrl, pyqtSignal, pyqtSlot, QVariant, Qt
from PyQt5.QtQml import qmlRegisterType, QQmlComponent, QQmlEngine
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtSql import QSqlDatabase, QSqlQuery, QSqlQueryModel
from PyQt5 import QtGui


class QtTabModel(QSqlQueryModel):
    def __init__(self):
        super(QtTabModel, self).__init__()

    def roleNames(self):
        roles = {
            Qt.UserRole + 1 : 'id',
            Qt.UserRole + 2 : 'name'
        }
        return roles

    def data(self, index, role):
        if role < Qt.UserRole:
            # caller requests non-UserRole data, just pass to papa
            return super(QtTabModel, self).data(index, role)

        # caller requests UserRole data, convert role to column (role - Qt.UserRole -1) to return correct data
        return super(QtTabModel, self).data(self.index(index.row(), role - Qt.UserRole -1), Qt.DisplayRole)

    @pyqtSlot(result=QVariant)  # don't know how to return a python array/list, so just use QVariant
    def roleNameArray(self):
        # This method is used to return a list that QML understands
        list = []
        # list = self.roleNames().items()
        for key, value in self.roleNames().items():
            list.append(value)

        return QVariant(list)

    @pyqtSlot('int', result=int)
    def rowToId(self, row):
        result = self.record(row).value("id")
        print("rowToId row=", row, " result=", result)
        return result


class LunchHelperModel(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.db = QSqlDatabase.addDatabase('QSQLITE')
        self.db.setDatabaseName('lunch.db')
        self.db.open()

        self.peopleModel = QtTabModel()
        self.restuarantIntersectionModel = QtTabModel()
        self.allRestuarantModel = QtTabModel()
        self.restaurantIntersectionIds = []


    peopleListChanged = pyqtSignal()
    @pyqtProperty(QtTabModel, notify=peopleListChanged)
    def peopleList(self):
        query = self.db.exec("SELECT * FROM person")
        self.peopleModel.setQuery(query)
        return self.peopleModel

    restaurantsIntersectionListChanged = pyqtSignal()
    @pyqtProperty(QtTabModel, notify=restaurantsIntersectionListChanged)
    def restaurantsIntersectionList(self):
        if len(self.restaurantIntersectionIds) != 0:
            query_str = "SELECT restaurant.id as id, restaurant.name  as name FROM restaurant, person_to_restaurant " \
                        "ON restaurant.id = person_to_restaurant.restaurant_id " \
                        "WHERE person_to_restaurant.person_id IN (%s) " \
                        "GROUP BY restaurant.id HAVING count(restaurant.id)=%d" % \
                            (','.join(map(str,self.restaurantIntersectionIds)), len(self.restaurantIntersectionIds))
        else:
            query_str = "SELECT * from restaurant"
        print(query_str)
        query = self.db.exec(query_str)
        self.restuarantIntersectionModel.setQuery(query)
        return self.restuarantIntersectionModel


    allRestaurantsListChanged = pyqtSignal()
    @pyqtProperty(QtTabModel, notify=allRestaurantsListChanged)
    def allRestaurantsList(self):
        query = self.db.exec("SELECT * FROM restaurant")
        self.allRestuarantModel.setQuery(query)
        return self.allRestuarantModel

    @pyqtSlot('QVariantList')
    def setRestaurantIntersectionIds(self, personIds):
        self.restaurantIntersectionIds = personIds
        self.restaurantsIntersectionListChanged.emit()

    @pyqtSlot('int', result=QVariant)
    def deletePersonById(self, personId):
        query_str = "DELETE FROM person WHERE id=%d" % (personId,)
        print(query_str)
        query = self.db.exec(query_str)
        if query.numRowsAffected() != 1:
            print("Rows affected=" + str(query.numRowsAffected()))
            return False
        self.peopleListChanged.emit()
        return True

    @pyqtSlot('int', result=QVariant)
    def deleteRestaurantById(self, restaurantId):
        query_str = "DELETE FROM restaurant WHERE id=%d" % (restaurantId,)
        print(query_str)
        query = self.db.exec(query_str)
        if query.numRowsAffected() != 1:
            print("Rows affected=" + str(query.numRowsAffected()))
            return False
        self.allRestaurantsListChanged.emit()
        return True

    @pyqtSlot('int', result=QVariant)
    def getPersonById(self, personId):

        query_str = "SELECT person.id, person.name FROM person WHERE person.id=%d" % (personId,)
        print(query_str)
        query = self.db.exec(query_str)
        if not query.next():
            print('Cannot find person id=', personId)
            return {'id':-1, 'name':'', 'restaurants':[]}

        personName = query.value("name")

        query_str = "SELECT restaurant.id FROM person_to_restaurant, restaurant ON person_to_restaurant.restaurant_id = restaurant.id WHERE person_to_restaurant.person_id=%d" % (personId,)
        print(query_str)
        query = self.db.exec(query_str)
        restaurants = []
        while query.next():
            restaurants.append(query.value(0))
        print('id=%d name=%s restaurants=%s' % (personId, personName, repr(restaurants)))

        return {'id':personId, 'name':personName, 'restaurants': restaurants}

    @pyqtSlot('QString', 'QVariantList', result=QVariant)
    def addPerson(self, name, restaurantIds):
        print("adding ", name, repr(restaurantIds))
        query = QSqlQuery(self.db)
        print(query.prepare("INSERT INTO person (name) VALUES(?)"))
        query.addBindValue(name)
        if not query.exec_():
            print(query.lastError().text())
            return False
        query.next()
        personId = query.lastInsertId()
        query.prepare("INSERT INTO person_to_restaurant (person_id, restaurant_id) VALUES(?, ?)")
        for restaurantId in restaurantIds:
            print("add link ", personId, restaurantId)
            query.addBindValue(personId)
            query.addBindValue(restaurantId)
            if not query.exec_():
                print(query.lastError().text())
                return False
        self.peopleListChanged.emit()
        return True

    def addRestaurantIdsToPerson(self, personId, restaurantIds):
        query = QSqlQuery(self.db)
        query.prepare("INSERT INTO person_to_restaurant (person_id, restaurant_id) VALUES(?, ?)")
        for restaurantId in restaurantIds:
            print("add link ", personId, restaurantId)
            query.addBindValue(personId)
            query.addBindValue(restaurantId)
            if not query.exec_():
                print(query.lastError().text())
                return False


    @pyqtSlot('QString', 'QVariantList', result=QVariant)
    def addPerson(self, name, restaurantIds):
        print("adding ", name, repr(restaurantIds))
        query = QSqlQuery(self.db)
        print(query.prepare("INSERT INTO person (name) VALUES(?)"))
        query.addBindValue(name)
        if not query.exec_():
            print(query.lastError().text())
            return False
        query.next()
        personId = query.lastInsertId()
        self.addRestaurantIdsToPerson(personId, restaurantIds)
        self.peopleListChanged.emit()
        return True

    @pyqtSlot('int', 'QString', 'QVariantList', result=QVariant)
    def editPerson(self, id, name, restaurantIds):
        query = QSqlQuery(self.db)
        query.prepare("UPDATE person SET name=? WHERE id=?")
        query.addBindValue(name)
        query.addBindValue(id)
        if not query.exec_():
            print(query.lastError().text())
            return False
        if query.numRowsAffected() != 1:
            print("Number of affected rows was ", query.numRowsAffected())
            return False

        self.db.exec("DELETE FROM person_to_restaurant WHERE person_id=%d" % (id,))
        self.addRestaurantIdsToPerson(id, restaurantIds)

        self.allRestaurantsListChanged.emit()
        self.restaurantsIntersectionListChanged.emit()
        return True

    @pyqtSlot('QString', 'QString', result=QVariant)
    def addRestaurant(self, name, comment):
        query = QSqlQuery(self.db)
        query.prepare("INSERT INTO restaurant (name, comment) VALUES(?, ?)")
        query.addBindValue(name)
        query.addBindValue(comment)
        if not query.exec_():
            print(query.lastError().text())
            return False
        self.allRestaurantsListChanged.emit()
        self.restaurantsIntersectionListChanged.emit()
        return True

    @pyqtSlot('int', result=QVariant)
    def getRestaurantById(self, restaurantId):
        query_str = "SELECT restaurant.name, restaurant.comment FROM restaurant WHERE restaurant.id=%d" % (restaurantId,)
        print(query_str)
        query = self.db.exec(query_str)
        if not query.next():
            print('Cannot find restaurant id=', restaurantId)
            return {'id':-1, 'name':'', 'restaurants':[]}

        result = {'id':restaurantId, 'name':query.value("name"), 'comment': query.value("comment")}
        print(repr(result))
        return result

    @pyqtSlot('int', 'QString', 'QString', result=QVariant)
    def editRestaurant(self, restaurantId, restaurantName, restaurantComment):
        print(repr([restaurantId, restaurantName, restaurantComment]))
        query = QSqlQuery(self.db)
        query.prepare("UPDATE restaurant SET name=?, comment=? WHERE id=?")
        query.addBindValue(restaurantName)
        query.addBindValue(restaurantComment)
        query.addBindValue(restaurantId)
        if not query.exec_():
            print(query.lastError().text())
            return False
        if query.numRowsAffected() != 1:
            print("Number of affected rows was ", query.numRowsAffected())
            return False
        self.allRestaurantsListChanged.emit()
        self.restaurantsIntersectionListChanged.emit()
        return True




if __name__ == '__main__':
    app = QApplication(sys.argv)
    app.setWindowIcon(QtGui.QIcon('images/daffy.ico'))
    dataList = LunchHelperModel(app)

    # Create the QML user interface.
    engine = QQmlApplicationEngine()

    context = engine.rootContext()
    context.setContextProperty('myModel', dataList)

    engine.load(QUrl.fromLocalFile('qml/ui.qml'))
    window = engine.rootObjects()[0]

    window.show()

    app.exec_()
