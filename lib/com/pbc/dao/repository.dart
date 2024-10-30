import 'dart:async';

import 'package:order_booker/com/pbc/model/outlet_areas.dart';
import 'package:order_booker/com/pbc/model/outlet_products_alternative_prices.dart';
import 'package:order_booker/com/pbc/model/outlet_products_prices.dart';
import 'package:order_booker/com/pbc/model/outlet_sub_areas.dart';
import 'package:order_booker/com/pbc/model/pci_sub_channel.dart';
import 'package:order_booker/com/pbc/model/pre_sell_outlets.dart';
import 'package:order_booker/com/pbc/model/product_lrb_types.dart';
import 'package:order_booker/com/pbc/model/product_sub_categories.dart';
import 'package:order_booker/com/pbc/model/products.dart';
import 'package:order_booker/com/pbc/model/user.dart';
import 'package:order_booker/com/pbc/model/user_features.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../globals.dart' as globals;
import '../model/OutletChannel.dart';
import '../model/PJP.dart';

class Repository {
  var database;
  Repository({this.database});
  static Database _db;
  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initdb();
    return _db;
  }
  Future<Database> getDatabaseObject(){
    return database;
  }

  initdb() async {
    // //print

    /*try{
     final Database db = await database;
     await db.delete('pre_sell_outlets2');
   }catch(error)
    {
      //print(error.toString());
    }*/
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'delivery_managerV92.db'),
      // When the database is first created, create a table to store dogs.
      onUpgrade: _onUpgrade,
      onCreate: (db, version) {
        //print('test');
        /* db.execute(
            "CREATE TABLE products_old( category_id INTEGER,category_label TEXT,sap_code INTEGER,product_id INTEGER,package_id INTEGER,package_label TEXT,package_sort_order INTEGER,liquid_in_ml  INTEGER,conversion_rate_in_ml  TEXT,brand_id INTEGER,brand_label TEXT,unit_per_sku INTEGER,is_visible INTEGER,type_id INTEGER,ssrb_type_id INTEGER,lrb_type_id INTEGER,is_other_brand INTEGER);"
        );*/
        print("CREATE TABLE spot_discount(product_id INTEGER, default_discount real, maximum_discount real,ChannelID INTEGER)");

        db.execute(
            "CREATE TABLE outlet_orders_images(id INTEGER, file_type_id TEXT, file TEXT,is_uploaded INTEGER DEFAULT 0,created_on TEXT)");
        //Created By Irteza
        db.execute(
            "CREATE TABLE selected_pjp(PJPID TEXT,PJPName TEXT, is_selected INTEGER DEFAULT 0)");
        db.execute(
            "CREATE TABLE update_location(IsAllow INTEGER)");
        db.execute(
            "CREATE TABLE outlet_no_orders_images(id INTEGER, file_type_id INTEGER, file TEXT,is_uploaded INTEGER DEFAULT 0)");
        db.execute(
            "CREATE TABLE outlet_Registration_images(id INTEGER, file_type_id TEXT, file TEXT,is_uploaded INTEGER DEFAULT 0)");
        //
        db.execute(
            "CREATE TABLE products( product_id INTEGER,product_label TEXT,package_id INTEGER,package_label TEXT,sort_order INTEGER,brand_id INTEGER,brand_label TEXT,unit_per_case INTEGER,lrb_type_id INTEGER);");
        db.execute(
            "CREATE TABLE pre_sell_outlets2(outlet_id INTEGER,outlet_name TEXT,day_number INTEGER,owner TEXT ,address TEXT,telephone TEXT,nfc_tag_id TEXT, visit_type INTEGER,lat TEXT,lng TEXT,accuracy TEXT,area_label TEXT, sub_area_label TEXT,is_alternate_visible INTEGER,pic_channel_id TEXT, channel_label TEXT, order_created_on_date TEXT, common_outlets_vpo_classifications TEXT , Visit TEXT, purchaser_name TEXT, purchaser_mobile_no TEXT, cache_contact_nic TEXT,IsGeoFence INTEGER,Radius INTEGER,channel_id INTEGER,channel_name TEXT,PJP INTEGER)");

        db.execute("CREATE TABLE product_lrb_types(id INTEGER,label TEXT)");

        db.execute(
            "CREATE TABLE product_sub_categories(id INTEGER,label TEXT)");

        db.execute(
            "CREATE TABLE outlet_product_prices(price_id INTEGER,outlet_id INTEGER,product_id INTEGER,raw_case REAL,unit TEXT)");

        db.execute(
            "CREATE TABLE outlet_orders(id INTEGER,outlet_id INTEGER,is_completed INTEGER,is_uploaded INTEGER,total_amount REAL,uuid TEXT,created_on TEXT,lat TEXT,lng TEXT,accuracy TEXT,PJP INTEGER)");

        db.execute(
            "CREATE TABLE outlet_order_items(id INTEGER,source_id INTEGER,order_id INTEGER,product_id INTEGER,discount REAL,quantity INTEGER,amount REAL,created_on TEXT,rate REAL,product_label TEXT, unit_quantity INTEGER, is_promotion INTEGER, promotion_id INTEGER,DiscountID INTEGER,defaultDiscount INTEGER,maximumDiscount INTEGER)");
        db.execute(
            "CREATE TABLE users(user_id INTEGER,display_name TEXT,designation TEXT,distributor_employee_id TEXT,password TEXT, created_on TEXT, department TEXT , IsOutletLocationUpdate INTEGER)");
        db.execute(
            "CREATE TABLE outlet_no_orders(id INTEGER,outlet_id INTEGER,reason_type_id INTEGER,is_uploaded INTEGER,uuid TEXT,created_on TEXT,lat TEXT,lng TEXT,accuracy TEXT ,PJP INTEGER)");

//added by farhan after danish code STARTS
        db.execute(
            "CREATE TABLE outlet_product_alternative_prices(product_id INTEGER,package_id INTEGER,package_label TEXT,brand_id INTEGER,brand_label TEXT,raw_case_price REAL,unit_price REAL,liquid_in_ml INTEGER)");

        db.execute("CREATE TABLE outlet_areas(id INTEGER,label TEXT)");

        db.execute(
            "CREATE TABLE outlet_sub_areas(id INTEGER,label TEXT,area_id INTEGER)");

        db.execute(
            "CREATE TABLE pci_sub_channel(id INTEGER,label TEXT,parent_channel_id INTEGER)");

        db.execute(
            "CREATE TABLE registered_outlets(id_for_update INTEGER,outlet_name TEXT,mobile_request_id TEXT,mobile_timestamp TEXT, channel_id INTEGER,area_label TEXT,sub_area_label TEXT,address TEXT, owner_name TEXT,owner_cnic TEXT, owner_mobile_no TEXT,purchaser_name TEXT,purchaser_mobile_no TEXT, is_owner_purchaser INTEGER, lat REAL, lng REAL, accuracy INTEGER, created_on TEXT,created_by INTEGER,is_uploaded INTEGER,is_new INTEGER,outletchannel INTEGER )");


        db.execute(

            "CREATE TABLE stock_position(product_id INTEGER,units REAL,raw_cases REAL)"
        );

        db.execute(

            "CREATE TABLE attendance(mobile_request_id TEXT,user_id INTEGER,attendance_type_id INTEGER,mobile_timestamp TEXT,lat REAL, lng REAL, accuracy INTEGER,is_uploaded INTEGER,uuid TEXT,image_path TEXT,is_photo_uploaded INTEGER)"
        );
        db.execute(
            "CREATE TABLE user_features(id INTEGER )");
        db.execute(
            "CREATE TABLE Outlets_channel (id INTEGER ,label TEXT)");

        db.execute(

            "CREATE TABLE merchandising(mobile_request_id TEXT,outlet_id INTEGER,user_id INTEGER,mobile_timestamp TEXT,lat REAL, lng REAL, accuracy INTEGER,is_completed INTEGER,uuid TEXT,image TEXT,type_id INTEGER,is_photo_uploaded INTEGER)"
        );

        db.execute(
            "CREATE TABLE outlet_mark_close(id INTEGER ,outlet_id INTEGER,image_path TEXT,is_uploaded INTEGER,is_photo_uploaded INTEGER,uuid TEXT,created_on TEXT,lat TEXT,lng TEXT,accuracy TEXT )");

        db.execute("CREATE TABLE spot_discount(DiscountID,product_id INTEGER, default_discount real, maximum_discount real,ChannelID INTEGER)");

        print("CREATE TABLE spot_discount(product_id INTEGER, default_discount real, maximum_discount real)");


        db.execute(
            "CREATE TABLE promotions_products(promotion_id INTEGER,package_id INTEGER,total_units INTEGER,brand_id INTEGER)");


        db.execute(
            "CREATE TABLE promotions_active(promotion_id INTEGER,outlet_id INTEGER)");

        db.execute(
            "CREATE TABLE promotions_products_free(promotion_id INTEGER,package_id INTEGER,total_units INTEGER, package_label TEXT, brand_id INTEGER, brand_label TEXT, unit_per_case INTEGER, product_id INTEGER)");



//added by farhan after danish code ENDS

        //print("db created");
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 4,
    );
    return database;
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
/*    if (oldVersion < newVersion) {
      db.execute("ALTER TABLE registered_outlets ADD COLUMN area_label text;");
      db.execute(
          "ALTER TABLE registered_outlets ADD COLUMN sub_area_label text;");
      print("haseeb called1");
    }*/
    print("haseeb called");
  }



  Future<void> insertPromotionsProducts(promotionId,packageId,totalUnits,brandId) async {
    await this.initdb();
    final Database db = await database;
    try {

      await db.rawInsert(
          "insert into promotions_products(promotion_id,package_id,total_units,brand_id) values  (?,?,?,?) ",
          [promotionId ,packageId ,totalUnits ,brandId ]);
    } catch (error) {
      //print(error);
    }
  }
  Future<void> insertPromotionsActive(promotionId,outletId) async {
    await this.initdb();
    final Database db = await database;
    try {

      await db.rawInsert(
          "insert into promotions_active(promotion_id,outlet_id) values  (?,?) ",
          [promotionId,outletId ]);
    } catch (error) {
      //print(error);
    }
  }
  Future<List<Map<String, dynamic>>>  SelectOutletByID(int outletId) async {
    await this.initdb();
    final Database db = await database;

    // Query the table for all The Dogs.
    List args = new List();
    args.add(outletId);

    final List<Map> maps =  await db.rawQuery('Select *from  pre_sell_outlets2 where outlet_id=?1 ', args);
    return maps;
  }
  Future<void> insertPromotionsProductsFree(promotionId,packageId,totalUnits, packageLabel, brandId, brandLabel, unitPerCase, productId) async {
    await this.initdb();
    final Database db = await database;
    try {

      await db.rawInsert(
          "insert into promotions_products_free(promotion_id,package_id,total_units, package_label, brand_id, brand_label, unit_per_case, product_id) values  (?,?,?,?,?,?,?,?) ",
          [promotionId,packageId,totalUnits, packageLabel, brandId, brandLabel, unitPerCase,productId ]);
    } catch (error) {
      //print(error);
    }
  }

  Future<List<Map<String, dynamic>>> getPromotionProductsFree(promotionId) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(promotionId);

    final List<Map> maps = await db.rawQuery(
        "select * from promotions_products_free where promotion_id=?1", args);
    print("maps.toString()" + maps.toString());

    return maps;
  }

  Future<int> getPromotionIdaa(outletId) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(outletId);

    final List<Map> maps = await db.rawQuery(
        "select * from promotions_active where outlet_id=?1", args);
    //print(maps.toString());
    int promotionId = 0;
    if(maps.isNotEmpty){
      promotionId = maps[0]['promotion_id'];
    }
    return promotionId;
  }

  Future<List<Map<String, dynamic>>> getPromotionalProduct(promotionId, packageId, brandId) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(promotionId);
    args.add(packageId);
    args.add(brandId);

    print('promotion_id:' + promotionId);
    print('package_id:' + packageId);
    print('brand_id' + brandId);
    final List<Map> maps = await db.rawQuery(
        "select * from promotions_products where promotion_id =?1 and package_id=?2 and brand_id=?3", args);
    //print(maps.toString());

    return maps;
  }

  Future<List<Map<String, dynamic>>> getAllPromotionalProducts() async {
    await this.initdb();
    final Database db = await database;
    List args = new List();

    final List<Map> maps = await db.rawQuery(
        "select * from promotions_products", args);
    print("promotions_products:"+maps.toString());

    return maps;
  }

  Future<int> getPromotionId(outletId, packageId, brandId) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(outletId);
    args.add(packageId);
    args.add(brandId);

    final List<Map> maps = await db.rawQuery(
        "select promotion_id from promotions_products where promotion_id in(select promotion_id from promotions_active where outlet_id=?1) and package_id=?2 and brand_id=?3", args);
    //print(maps.toString());
    int promotionId = 0;
    if(maps.isNotEmpty){
      promotionId = maps[0]['promotion_id'];
    }
    return promotionId;
  }


  Future<List<Map<String, dynamic>>> getAllPromotionalProduct(outletId, packageId, brandId) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(outletId);
    args.add(packageId);
    args.add(brandId);

    final List<Map> maps = await db.rawQuery(
        "select * from promotions_products where promotion_id in(select promotion_id from promotions_active where outlet_id=?1) and package_id=?2 and brand_id=?3", args);
    print("select:" + maps.toString());

    return maps;
  }
  Future<List<Map<String, dynamic>>> getAllAddedItemsOfOrderByIsPromotion(
      int orderId, isPromotion) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(orderId);
    args.add(isPromotion);
    print("orderId in getAllAddedItemsOfOrderByIsPromotion"+orderId.toString());
    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select * from outlet_order_items where order_id=?1 and is_promotion=?2", args);
    //print(maps);

    return maps;
  }
  Future changePromotionProduct(id, productId, productLabel) async {
    await this.initdb();
    final Database db = await database;
//print("ORDER ID"+orderId.toString());

    List args = new List();

    args.add(productId);
    args.add(productLabel);
    args.add(id);

    await db.rawUpdate(
        'update outlet_order_items set product_id=?1,product_label=?2 where id=?3',
        args);
    return true;
  }
  Future UpdatePJPselection(PJPID) async {
    await this.initdb();
    final Database db = await database;
//print("ORDER ID"+orderId.toString());
    List args = new List();
    args.add(PJPID);
    await db.rawUpdate(
        'update selected_pjp set is_selected=1 where PJPID=?1',
        args);
    return true;
  }


  Future<void> deletePromotionsProductsFree() async {
    final Database db = await database;
    await db.delete('promotions_products_free');
  }


  Future<void> deletePromotionsActive() async {
    final Database db = await database;
    await db.delete('promotions_active');
  }

  Future<void> deletePromotionsProducts() async {
    final Database db = await database;
    await db.delete('promotions_products');
  }

  void saveOutletMarkClose(id,outletId, imagePath, lat, lng, accuracy, uuid) async {
    await this.initdb();
    final Database db = await database;
    try {
      await db.rawInsert(
          "insert into outlet_mark_close(id,outlet_id, image_path, lat, lng, accuracy, uuid, created_on, is_uploaded) values  (?,?, ?, ?, ?, ?, ?,DATETIME('now','5 hours'), 0) ",
          [id,outletId, imagePath, lat, lng, accuracy, uuid]);
    } catch (error) {
      //print(error);
    }
  }
  Future<void> insertSpotDiscount(DiscountID,productId,defaultDiscount, maximumDiscount,ChannelID) async {
    await this.initdb();
    final Database db = await database;
    try {
      await db.rawInsert("insert into spot_discount(DiscountID,product_id,default_discount, maximum_discount,ChannelID) values  (?,?,?,?,?) ", [DiscountID,productId,defaultDiscount, maximumDiscount,ChannelID]);
    } catch (error) {
      //print(error);
    }
  }

  Future<void> deleteAllSpotDiscount() async {
    final Database db = await database;
    await db.delete('spot_discount');
  }

/*  Future<Map> getSpotDiscount(productId,ChannelID) async {
    // Get a reference to the database.
    await this.initdb();
    final Database db = await database;

    // Query the table for all The Dogs.
    List args = new List();
    args.add(productId);
    args.add(ChannelID);

    final List<Map> maps = await db.rawQuery(
        "select *  from spot_discount where product_id=?1 and ChannelID=?2",
        args);

    return maps.isEmpty ? null : maps[0];

  }*/
  Future<Map> getSpotDiscount(productId, ChannelID) async {
    // Get a reference to the database.
    await this.initdb();
    final Database db = await database;

    // Query to get the ChannelID for the given product_id
    final List<Map> initialQuery = await db.rawQuery(
        "select ChannelID from spot_discount where product_id = ?",
        [productId]
    );

    if (initialQuery.isEmpty) {
      return null;
    }

    final int localChannelID = initialQuery[0]['ChannelID'];

    List<Map> maps;

    if (localChannelID == 0) {
      maps = await db.rawQuery(
          "select * from spot_discount where product_id = ?",
          [productId]
      );
      print("localChannelID is 0");
    } else {
      maps = await db.rawQuery(
          "select * from spot_discount where product_id = ? and ChannelID = ?",
          [productId, ChannelID]
      );
      print("localChannelID is not 0");

    }

    return maps.isEmpty ? null : maps[0];
  }



  Future markOutletMarkCloseUploaded(int id) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(id);
    await db.rawUpdate(
        'update outlet_mark_close set is_uploaded=1 where id=?1 ', args);
    return true;
  }

  Future markOutletMarkCloseUploadedPhoto(int id) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(id);
    await db.rawUpdate(
        'update outlet_mark_close set is_photo_uploaded=1 where id=?1 and is_uploaded=1', args);
    return true;
  }
  Future<List<Map<String, dynamic>>> getAllOutletMarkClose(isUploaded) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(isUploaded);

    final List<Map> maps = await db.rawQuery(
        "select * from outlet_mark_close where is_uploaded=?1", args);
    //print(maps.toString());
    return maps;
  }
  Future<List<Map<String, dynamic>>> getPJPs() async {
    await this.initdb();
    final Database db = await database;
    //List args = new List();
   // args.add(isUploaded);

    final List<Map> maps = await db.rawQuery(
        "select * from selected_pjp");
    //print(maps.toString());
    return maps;
  }
  Future<List<Map<String, dynamic>>> getSelectedPJPs() async {
    await this.initdb();
    final Database db = await database;
    //List args = new List();
   // args.add(isUploaded);

    final List<Map> maps = await db.rawQuery(
        "select PJPID from selected_pjp where is_selected=1");
    //print(maps.toString());
    return maps;
  }

  Future<List<Map<String, dynamic>>> updateisseleted() async {
    await this.initdb();
    final Database db = await database;
    //List args = new List();
    // args.add(isUploaded);

    final List<Map> maps = await db.rawQuery(
        "update  selected_pjp set is_selected=0");
    //print(maps.toString());
    return maps;
  }
//
  Future<void> deleteAllUserFeatures() async {
    final Database db = await database;
    await db.delete('user_features');
  }
  Future<void> deleteAllOutletChannel() async {
    final Database db = await database;
    await db.delete('Outlets_channel');
  }


  Future<List> isUserAllowed(int featureId) async {

    await initdb();
    final Database db = await database;

    List args = new List();
    args.add(featureId);
    List maps = await db.rawQuery("select id from user_features where id=?1",args);
    print(maps.toString());

    return maps;
  }

  Future<void> insertFeatures(UserFeatures userFeature) async {
    final Database db = await database;
    try {
      await db.insert(
        'user_features',
        userFeature.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      print("ERROR in inserting UserFeatures : "+error);
      //print(error);
    }
  }
  Future<void> insertChannel(OutletChannel outletchannel) async {
    final Database db = await database;
    try {
      await db.insert(
        'Outlets_channel',
        outletchannel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      print("ERROR in inserting UserFeatures : "+error);
      //print(error);
    }
  }

  Future<void> deleteAllStockPosition() async {
    final Database db = await database;
    await db.delete('stock_position');
  }
  void insertStockPosition( productId, units, rawCases) async {

    await this.initdb();
    final Database db = await database;
    try{
      await db.rawInsert('insert into stock_position (product_id,units, raw_cases) values  (?,?,?) '
          ,[productId,units,rawCases]);
    }catch(error){

      print(error);
    }


  }

  Future<double> getAvailableStock(productId) async {
    // Get a reference to the database.
    await this.initdb();
    final Database db = await database;

    // Query the table for all The Dogs.
    List args = new List();
    args.add(productId);

    final List<Map> maps = await db.rawQuery(
        "select raw_cases  from stock_position where product_id=?1 ",
        args);

    print('stock:'+maps[0]['raw_cases'].toString());
    return maps[0]['raw_cases'];
  }

  Future<List<Map>> getStockData() async {
    // Get a reference to the database.
    await this.initdb();
    final Database db = await database;

    // Query the table for all The Dogs.
    List args = new List();
    //args.add(productId);

    final List<Map> maps = await db.rawQuery(
        " select brand_label, package_label, (select raw_cases from stock_position sp where p.product_id = sp.product_id) stock from products p order by sort_order, brand_label",
        );

    return maps;
  }

  Future<void> insertProduct(Products product) async {
    // Get a reference to the database.
    final Database db = await database;
    try {
      await db.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      //print("//print ERROR");
      //print(error);
    }
  }

  Future<void> deleteAllProducts() async {
    final Database db = await database;
    await db.delete('products');
  }

  Future<void> deleteAllPreSellOutlet() async {
    final Database db = await database;
    await db.delete('pre_sell_outlets2');
  }

  Future<void> insertPreSellOutlet(PreSellOutlets outlet) async {
    // Get a reference to the database.
    final Database db = await database;

    try {
      await db.insert(
        'pre_sell_outlets2',
        outlet.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      print("ERROR ==>> "+error.toString());
    }
  }

  Future<void> deleteAllProductsLrbTypes() async {
    final Database db = await database;
    await db.delete('product_lrb_types');
  }

  Future<void> insertProductsLrbTypes(ProductsLrbTypes lrbTypes) async {
    // Get a reference to the database.
    final Database db = await database;

    try {
      await db.insert(
        'product_lrb_types',
        lrbTypes.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      //print("ERROR ==>> "+error.toString());
    }
  }

  Future<void> deleteAllSubCategories() async {
    final Database db = await database;
    await db.delete('product_sub_categories');
  }

  Future<void> insertProductsSubCategories(
      ProductSubCategories subCategories) async {
    // Get a reference to the database.
    final Database db = await database;

    try {
      await db.insert(
        'product_sub_categories',
        subCategories.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      //print("ERROR ==>> "+error.toString());
    }
  }

  Future<void> insertOutletProductsPrices(
      OutletProductsPrices ProductsPrices) async {
    // Get a reference to the database.
    final Database db = await database;
    try {
      await db.insert(
        'outlet_product_prices',
        ProductsPrices.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      //print("ERROR outlet_product_prices : ");
      //print(error);
    }
  }

  Future<void> deleteAllOutletProductsPrices() async {
    final Database db = await database;
    await db.delete('outlet_product_prices');
  }

  Future<List<Map<String, dynamic>>> getActiveProductPriceList(
      int productId, int outletId) async {
    // Get a reference to the database.
    await this.initdb();
    final Database db = await database;
    //print("Product ID "+productId.toString());
    //print("outletId ID "+outletId.toString());
    // Query the table for all The Dogs.
    List args = new List();
    args.add(outletId);
    args.add(productId);
    final List<Map> maps = await db.rawQuery(
        "select *  from outlet_product_prices where outlet_id=?1 and product_id=?2 limit 1",
        args);

    //print(maps);
    return maps;
  }
  Future<List<Map<String, dynamic>>> GetOutletformID(
      int outletId) async {
    // Get a reference to the database.
    await this.initdb();
    final Database db = await database;
    //print("Product ID "+productId.toString());
    //print("outletId ID "+outletId.toString());
    // Query the table for all The Dogs.
    List args = new List();
    args.add(outletId);
    final List<Map> maps = await db.rawQuery(
        "select *  from pre_sell_outlets2 where outlet_id=?1",
        args);

    //print(maps);
    return maps;
  }
  Future<List<Map<String, dynamic>>> getPreSellOutletsByIsVisible(
      int dayNumber, String name, int isVisible, String pjp) async {
    // Get a reference to the database.
    await this.initdb();
    final Database db = await database;

    String OutletQuery = "";
    List<String> searchOutletTerms = name.split(" ");
    for (int i = 0; i < searchOutletTerms.length; i++) {
      if (i > 0) {
        OutletQuery += " OR ";
      }
      OutletQuery +=
      " (outlet_id LIKE '%${searchOutletTerms[i]}%' OR area_label LIKE '%${searchOutletTerms[i]}%' OR sub_area_label LIKE '%${searchOutletTerms[i]}%' OR outlet_name LIKE '%${searchOutletTerms[i]}%' OR address LIKE '%${searchOutletTerms[i]}%') ";
    }

    // Visible Query
    String visibleQuery = isVisible != -1
        ? " AND is_alternate_visible = $isVisible "
        : "";

    // PJP Query
    String pjpQuery = pjp.isNotEmpty
        ? " AND PJP LIKE '$pjp' "  // Replace 'pjp_column' with the actual column name that stores the PJP values.
        : "";

    List<Map> maps;
    try {
      String query = "SELECT * FROM pre_sell_outlets2 "
          "WHERE day_number = $dayNumber "
          "$visibleQuery "
          "$pjpQuery "
          "AND ($OutletQuery) "
          "GROUP BY outlet_id "
          "LIMIT 500";

      print(query);

      maps = await db.rawQuery(query);
    } catch (e) {
      print("Error: $e");
      return [];
    }

    return maps;
  }


  Future<List<Map<String, dynamic>>> getTotalOutlets(int dayNumber , pjp) async {
    // Get a reference to the database.
    await this.initdb();
    final Database db = await database;

    // Query the table for all The Dogs.
    List args = new List();
    args.add(dayNumber);
    args.add(pjp);

    final List<Map> maps = await db.rawQuery(
        "select count(*) as totalOutlets from pre_sell_outlets2 where day_number=?1 and PJP=?2  and is_alternate_visible=" + globals.isAlternative.toString(),
        args);

    //print(maps);
    return maps;
  }

  Future<int> getTotalOrders(pjp) async {
    // Get a reference to the database.
     
    await this.initdb();
    final Database db = await database;
    int totoalVisits = 0;
    List args = new List();
    args.add(pjp);
    final List<Map> maps = await db.rawQuery(
        "SELECT COUNT(DISTINCT outlet_id) AS totalOrders FROM outlet_orders WHERE PJP = ?1 AND date(created_on) = date('now') AND is_completed = 1",args);
    totoalVisits = maps[0]['totalOrders'];
    return totoalVisits;
  }

  Future<int> getTotalNoOrders(pjp) async {
    // Get a reference to the database.
    await this.initdb();
    final Database db = await database;
    int totoalVisits = 0;
    List args = new List();
    args.add(pjp);

    final List<Map> maps1 = await db.rawQuery(
        "select COUNT(DISTINCT outlet_id) as totalNoOrders from outlet_no_orders where PJP=?1 and date(created_on)=date('now') ",args);
    totoalVisits = maps1[0]['totalNoOrders'];
    return totoalVisits;
  }
  Future<int> getTotalOutletClosed() async {
    // Get a reference to the database.
    await this.initdb();
    final Database db = await database;
    int totoalVisits = 0;

    final List<Map> maps1 = await db.rawQuery(
        "select count(*) as totalNoOrders from outlet_mark_close where date(created_on)=date('now') ");
    totoalVisits = maps1[0]['totalNoOrders'];
    return totoalVisits;
  }

  Future<List<Map<String, dynamic>>> getProducts(
       lrbTypeId,  brandId) async {
    await this.initdb();
    final Database db = await database;
    // Query the table for all The Dogs.
    List<Map> maps = null;
    if (lrbTypeId == 0 && brandId == 0) {
      maps = await db.rawQuery(
          "select * from products  order by package_label asc limit 50");
    } else if (lrbTypeId != 0 && brandId == 0) {
      List args = new List();
      args.add(lrbTypeId);
      maps = await db.rawQuery(
          "select * from products where lrb_type_id=?1  order by package_label asc limit 50",
          args);
    } else if (lrbTypeId == 0 && brandId != 0) {
      List args = new List();
      args.add(brandId);
      maps = await db.rawQuery(
          "select * from products where brand_id=?1  order by package_label asc limit 50",
          args);
    } else if (lrbTypeId != 0 && brandId != 0) {
      List args = new List();
      args.add(lrbTypeId);
      args.add(brandId);
      maps = await db.rawQuery(
          "select * from products where lrb_type_id=?1 and brand_id=?2 order by package_label asc limit 50",
          args);
    }

    return maps;
  }
  Future<List<Map<String, dynamic>>> getProductsByPackageIdAndBrandId(
      packageId,  brandId) async {
    await this.initdb();
    final Database db = await database;
    // Query the table for all The Dogs.
    List<Map> maps = null;
    if (packageId == 0 && brandId == 0) {
      maps = await db.rawQuery(
          "select * from products  order by is_suggestion desc limit 500");
    } else if (packageId != 0 && brandId == 0) {
      List args = new List();
      args.add(packageId);
      maps = await db.rawQuery(
          "select * from products where package_id=?1  order by package_label asc limit 500",
          args);
    } else if (packageId == 0 && brandId != 0) {
      List args = new List();
      args.add(brandId);
      maps = await db.rawQuery(
          "select * from products where brand_id=?1  order by package_label asc limit 500",
          args);
    } else if (packageId != 0 && brandId != 0) {
      List args = new List();
      args.add(packageId);
      args.add(brandId);
      maps = await db.rawQuery(
          "select * from products where package_id=?1 and brand_id=?2 order by package_label asc limit 500",
          args);
    }

    return maps;
  }
  Future<List<Map<String, dynamic>>> getProductsLrbTypes(String name) async {
    await this.initdb();
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery("select * from product_lrb_types");
    //print("LRB TYPES"+maps.toString());
    return maps;
  }

  Future<List<Map<String, dynamic>>> getProductsSubCategories(
      String name) async {
    await this.initdb();
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map> maps = await db
        .rawQuery("select * from product_sub_categories order by label asc");
    return maps;
  }

  Future<List<Map<String, dynamic>>> getProductsSubCategoriesByCategoryId(
      int categoryId) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(categoryId);

    // Query the table for all The Dogs.
    String qry =
        "select * from product_sub_categories where id in(select brand_id from products where lrb_type_id=?1)  order by label asc";
    if (categoryId == 0) {
      qry =
          "select * from product_sub_categories where ?1=?1   order by label asc";
    }
    //print(categoryId.toString() + ":" +qry);
    final List<Map> maps = await db.rawQuery(qry, args);
    return maps;
  }

  Future<List<Map<String, dynamic>>> getProductsBySerachMethod(
      int lrbTypeId, int brandId, String searchProduct) async {
    await this.initdb();
    final Database db = await database;
    // Query the table for all The Dogs.
    List<Map> maps = null;
    String ProductQuery = "";
    List SearchProductTerms = searchProduct.split(" ");
    for (int i = 0; i < SearchProductTerms.length; i++) {
      if (i > 0) {
        ProductQuery += " and ";
      }
      ProductQuery +=
          "  (product_label like '%" + SearchProductTerms[i] + "%') ";
    }
    print(ProductQuery);
    if (lrbTypeId == 0 && brandId == 0) {
      List args = new List();
      args.add(ProductQuery);
      maps = await db.rawQuery("select * from products where " +
          ProductQuery +
          "  order by package_label asc limit 50");
    } else if (lrbTypeId != 0 && brandId == 0) {
      List args = new List();
      args.add(lrbTypeId);
      // args.add(ProductQuery);
      maps = await db.rawQuery(
          "select * from products where lrb_type_id=?1 and " +
              ProductQuery +
              "  order by package_label asc limit 50",
          args);
    } else if (lrbTypeId == 0 && brandId != 0) {
      List args = new List();
      args.add(brandId);
      // args.add(ProductQuery);
      maps = await db.rawQuery(
          "select * from products where brand_id=?1 and " +
              ProductQuery +
              "   order by package_label asc limit 50",
          args);
    } else if (lrbTypeId != 0 && brandId != 0) {
      List args = new List();
      args.add(lrbTypeId);
      args.add(brandId);
      // args.add(ProductQuery);
      maps = await db.rawQuery(
          "select * from products where lrb_type_id=?1 and brand_id=?2  and  " +
              ProductQuery +
              "  order by package_label asc limit 50",
          args);
    }
    return maps;
  }

  Future<void> deleteAllIncompleteOrder(outletId) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(outletId);

    int isdeleted = await db.rawDelete(
        "delete from outlet_orders where outlet_id=?1 and is_completed=0",
        args);
    if (isdeleted > 0) {
      print("Deleted incomplete order");

    } else {
      print("Not Deleted incomplete order");

    }
  }

  void deleteNoOrderReasons() async {
    final Database db = await database;
    await db.rawDelete("delete from no_order_reasons");
  }

  Future<void> deletePastOrders(outletId) async {
    final Database db = await database;
    List args = new List();
    args.add(outletId);

    int isdeleted = await db.rawDelete(
        "delete from outlet_orders where outlet_id=?1 and is_completed=0",
        args);
    if (isdeleted > 0) {
      //print("Deleted Unsed");
      return true;
    } else {
      //print("not Deleted Unsed");
      return false;
    }
  }

  Future initOrder(id, outletId, isCompleted, isUploaded, totalAmount, uuid,
      createdOn, lat, lng, accuracy,PJP) async {
    await this.initdb();
    final Database db = await database;

    int i = 0;
    try {
      i = await db.rawInsert(
          'insert into outlet_orders (id,outlet_id,is_completed,is_uploaded,total_amount,uuid,created_on, lat, lng, accuracy,PJP) values  (?,?,?,?,?,?,DATETIME("now","5 hours"),?,?,?,?) ',
          [
            id,
            outletId,
            isCompleted,
            isUploaded,
            totalAmount,
            uuid,
            lat,
            lng,
            accuracy,
            PJP
          ]);
    } catch (error) {
      //print("//print ERROR");
      //print(error);
    }
    if (i > 0) {
      //print("created");
      return true;
    } else {
      //print("not created");
      return false;
    }
  }
  Future initOrder2(id, isCompleted, isUploaded, totalAmount, uuid,
      createdOn, lat, lng, accuracy,PJP) async {
    await this.initdb();
    final Database db = await database;
    print("dsdsadsadsa");

    int i = 0;
    try {
      i = await db.rawInsert(
          'insert into outlet_orders (id,is_completed,is_uploaded,total_amount,uuid,created_on, lat, lng, accuracy,PJP) values  (?,?,?,?,?,DATETIME("now","5 hours"),?,?,?,?) ',
          [
            id,
            isCompleted,
            isUploaded,
            totalAmount,
            uuid,
            lat,
            lng,
            accuracy,
            PJP
          ]);
    } catch (error) {
      //print("//print ERROR");
      print("sad"+error);
    }
    if (i > 0) {
      print("created");
      return true;
    } else {
      print("not created");
      return false;
    }
  }
  void insertNoOrderReason(id, label) async {
    await this.initdb();
    final Database db = await database;
    try {
      await db.rawInsert(
          'insert into no_order_reasons (id,label) values  (?,?) ',
          [id, label]);
    } catch (error) {
      //print(error);
    }
  }

  void saveNoOrder(id, outletId, reasonTypeId, lat, lng, accuracy, uuid,PJP) async {
    await this.initdb();
    final Database db = await database;
    try {
      print("uuid======"+uuid);
      await db.rawInsert(
          "insert into outlet_no_orders (id, outlet_id, reason_type_id, lat, lng, accuracy, uuid, created_on, is_uploaded,PJP) values  (?, ?, ?, ?, ?, ?, ?,DATETIME('now','5 hours'), 0,?) ",
          [id, outletId, reasonTypeId, lat, lng, accuracy, uuid,PJP]);
    } catch (error) {
      //print(error);
    }
  }

  Future<List<Map<String, dynamic>>> getAllNoOrders(isUploaded) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(isUploaded);

    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select * from outlet_no_orders where is_uploaded=?1", args);
    //print(maps.toString());
    return maps;
  }

  Future<List<Map<String, dynamic>>> getAllOrders(
      int outletId, int isCompleted) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(outletId);
    args.add(isCompleted);

    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select * from outlet_orders where outlet_id=?1 and is_completed=?2",
        args);
    print(maps.toString());
    return maps;
  }

  Future<List<Map<String, dynamic>>> getAllOrdersunregistered(
       int isCompleted) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(isCompleted);

    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select * from outlet_orders where  is_completed=?1",
        args);
    print(maps.toString());
    return maps;
  }
  Future<List<Map<String, dynamic>>> getAllOrdersunregistered2(
      int orderid) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(orderid);

    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select * from outlet_orders where  id=?1",
        args);
    print(maps.toString());
    return maps;
  }
  Future<List<Map<String, dynamic>>> getNoOrderReasons() async {
    await this.initdb();
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery("select * from no_order_reasons");
    //print(maps.toString());
    return maps;
  }

  Future<List<Map<String, dynamic>>> getAllOrdersByIsUploaded(
      int isUploaded) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(isUploaded);
    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select * from outlet_orders where is_completed=1 and is_uploaded=?1",
        args);
    //print(maps.toString());
    return maps;
  }

  Future<List<Map<String, dynamic>>> getAllOrdersForSyncReport() async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    //args.add(isUploaded);
    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select id,outlet_id,total_amount,is_uploaded,(select outlet_name from pre_sell_outlets2 pso where pso.outlet_id=oo.outlet_id) outlet_name from outlet_orders oo where (is_completed = 1 and date(created_on)=date('now') and is_uploaded=1) or (is_completed = 1  and is_uploaded=0)");
    //print(maps.toString());
    return maps;
  }

  Future<List<Map<String, dynamic>>> getAllAttendanceForSyncReport() async {
    await this.initdb();
    final Database db = await database;
    List args = new List();

    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select * from attendance where date(mobile_timestamp) = date('now')",
        args);

    return maps;
  }

  Future getOrderItemInfo(int orderId, int productId) async {
    await this.initdb();
    final Database db = await database;
    List args1 = new List();
    args1.add(orderId);
    args1.add(productId);
    final List<Map> maps = await db.rawQuery(
        "select * from outlet_order_items where order_id=?1 and product_id=?2",
        args1);
    return maps;
  }

  /*Future addItemToCurrentOrderV0(int orderId, List item) async {
    await this.initdb();
    final Database db = await database;
//print("ORDER ID"+orderId.toString());
    double totalAmount = 0.0;
    for (int i = 0; i < item.length; i++) {
      List args = new List();
      args.add(orderId);
      args.add(item[i]['product_id']);
      args.add(item[i]['discount']);
      args.add(item[i]['quantity']);
      args.add(item[i]['amount']);
      double Amount = item[i]['amount'];
      args.add(item[i]['created_on']);
      args.add(item[i]['rate']);
      args.add(item[i]['product_label']);
      totalAmount += Amount;

      List args1 = new List();
      args1.add(orderId);
      args1.add(item[i]['product_id']);
      final List<Map> maps = await db.rawQuery(
          "select * from outlet_order_items where order_id=?1 and product_id=?2",
          args1);
      if (maps.isEmpty) {
        await db.rawInsert(
            'insert into outlet_order_items (order_id ,product_id ,discount,quantity ,amount ,created_on,rate,product_label) values  (?,?,?,?,?,?,?,?) ',
            args);
      } else {
        List args2 = new List();
        args2.add(item[i]['quantity']);
        args2.add(item[i]['discount']);
        args2.add(item[i]['amount']);
        args2.add(item[i]['rate']);
        args2.add(orderId);
        args2.add(item[i]['product_id']);
        await db.rawUpdate(
            'update outlet_order_items set quantity=?1,discount=?2,amount=?3, rate=?4 where order_id=?5 and product_id=?6',
            args2);
      }
    }
    List args1 = new List();
    args1.add(orderId);
    final List<Map> maps = await db.rawQuery(
        "select sum(amount) amount from outlet_order_items where order_id=?1",
        args1);
    if(maps.isNotEmpty){
      totalAmount = maps[0]['amount'];
    }
    List args = new List();
    args.add(orderId);
    args.add(totalAmount);
    await db.rawUpdate(
        'update outlet_orders set is_completed=0,total_amount=?2 where id=?1 ',
        args);
    return true;
  }*/

  Future<int> addItemToCurrentOrder(int orderId, List item, isForcedNewEntry) async {
    await this.initdb();
    final Database db = await database;
    int isNewEntry = 0;
    print("ORDER ID: " + orderId.toString());
    double totalAmount = 0.0;

    for (int i = 0; i < item.length; i++) {
      List args = [];
      args.add(orderId);
      args.add(item[i]['product_id']);
      args.add(item[i]['discount']);
      args.add(item[i]['quantity']);
      args.add(item[i]['amount']);
      double Amount = item[i]['amount'];
      args.add(item[i]['created_on']);
      args.add(item[i]['rate']);
      args.add(item[i]['product_label']);
      args.add(item[i]['unit_quantity']);
      args.add(item[i]['is_promotion']);
      args.add(item[i]['promotion_id']);
      args.add(item[i]['id']);
      args.add(item[i]['source_id']);
      args.add(item[i]['DiscountID']);
      args.add(item[i]['defaultDiscount']);
      args.add(item[i]['maximumDiscount']);
      totalAmount += Amount;
      print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
      print(item[i]['discount'].toString());
      print(item[i]['quantity'].toString());
      double withoutdiscountamount = 0.0;
      List args1 = [];
      args1.add(orderId);
      args1.add(item[i]['product_id']);

      // Print SELECT query
      print("Executing SELECT query: select * from outlet_order_items where order_id=${args1[0]} and product_id=${args1[1]}");
      final List<Map> maps = await db.rawQuery(
          "select * from outlet_order_items where order_id=?1 and product_id=?2",
          args1
      );

      if (isForcedNewEntry == 1) {
        // Print INSERT query for forced new entry
        print("Executing INSERT query (forced new entry): insert into outlet_order_items with args: $args");
        await db.rawInsert(
            'insert into outlet_order_items (order_id ,product_id ,discount,quantity ,amount ,created_on,rate,'
                'product_label, unit_quantity, is_promotion, promotion_id, id, source_id,DiscountID,defaultDiscount,maximumDiscount) values  (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
            args
        );
      } else if (maps.isEmpty) {
        isNewEntry = 1;
        // Print INSERT query for new entry
        print("Executing INSERT query (new entry): insert into outlet_order_items with args: $args");
        await db.rawInsert(
            'insert into outlet_order_items (order_id ,product_id ,discount,quantity ,amount ,created_on,rate,'
                'product_label, unit_quantity, is_promotion, promotion_id,id,source_id,DiscountID,defaultDiscount,maximumDiscount) values  (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
            args
        );
      } else {
        List args2 = [];
        args2.add(item[i]['quantity']);
        args2.add(item[i]['discount']);
        args2.add(item[i]['amount']);
        args2.add(item[i]['rate']);
        args2.add(orderId);
        args2.add(item[i]['product_id']);
        args2.add(item[i]['unit_quantity']);
        args2.add(item[i]['is_promotion']);
        args2.add(item[i]['promotion_id']);

        if (item[i]['is_promotion'] == 0) {
          // Print UPDATE query for non-promotion
          print("Executing UPDATE query (non-promotion): update outlet_order_items with args: $args2");
          await db.rawUpdate(
              'update outlet_order_items set quantity=?1,discount=?2,amount=?3, rate=?4, unit_quantity=?7,is_promotion=?8, promotion_id=?9 where order_id=?5 and product_id=?6',
              args2
          );
        } else {
          // Print UPDATE query for promotion
          print("Executing UPDATE query (promotion): update outlet_order_items with args: $args2");
          await db.rawUpdate(
              'update outlet_order_items set quantity=?1,discount=?2,amount=?3, rate=?4, unit_quantity=?7,is_promotion=?8, promotion_id=?9 where order_id=?5 and product_id=?6 and promotion_id=?9',
              args2
          );
        }
      }
    }

    List args = [];
    args.add(orderId);
    args.add(totalAmount);

    // Print UPDATE query for outlet_orders
    print("Executing UPDATE query for outlet_orders: update outlet_orders set total_amount=${args[1]} where id=${args[0]}");
    await db.rawUpdate(
        'update outlet_orders set is_completed=0,total_amount=?2 where id=?1',
        args
    );

    return isNewEntry;
  }


  Future<List<Map<String, dynamic>>> getProductById(productId) async {
    await this.initdb();
    final Database db = await database;
    // Query the table for all The Dogs.
    List<Map> maps = null;

    List args = new List();
    args.add(productId);

    maps = await db.rawQuery(
        "select * from products where  product_id=?1 ",
        args);
    return maps;
  }

  Future completeOrder(lat, lng, accuracy, int outletId) async {
    await this.initdb();
    final Database db = await database;
    List args = [];

    // Get the current time in the local time zone
    String currentTime = DateTime.now().toString(); // This will be in local time

    args.add(lat);
    args.add(lng);
    args.add(accuracy);
    args.add(currentTime); // Add the local time to the arguments
    args.add(outletId);

    // Print the query for debugging
    print(
        'UPDATE outlet_orders SET is_completed=1, lat=$lat, lng=$lng, accuracy=$accuracy, created_on=$currentTime WHERE outlet_id=$outletId');

    // Execute the query
    await db.rawUpdate(
      'UPDATE outlet_orders SET is_completed=1, lat=?1, lng=?2, accuracy=?3, created_on=?4 WHERE outlet_id=?5',
      args,
    );

    return true;
  }

  Future completeOrder2(lat, lng, accuracy, int orderID) async {
    await this.initdb();
    final Database db = await database;
    List args = [];

    // Get the current time in the local time zone
    String currentTime = DateTime.now().toString(); // This will be in local time

    args.add(lat);
    args.add(lng);
    args.add(accuracy);
    args.add(currentTime); // Add the local time to the arguments
    args.add(orderID);

    // Print the query for debugging
    print(
        'UPDATE outlet_orders SET is_completed=1, lat=$lat, lng=$lng, accuracy=$accuracy, created_on=$currentTime WHERE id=$orderID');

    // Execute the query
    await db.rawUpdate(
      'UPDATE outlet_orders SET is_completed=1, lat=?1, lng=?2, accuracy=?3, created_on=?4 WHERE id=?5',
      args,
    );

    return true;
  }

  Future markOrderUploaded(int orderId) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(orderId);
    await db.rawUpdate(
        'update outlet_orders set is_uploaded=1 where id=?1 ', args);
    return true;
  }

  Future markNoOrderUploaded(int orderId) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(orderId);
    await db.rawUpdate(
        'update outlet_no_orders set is_uploaded=1 where id=?1 ', args);
    return true;
  }

  Future markOutletUploaded(int orderId) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(orderId);
    await db.rawUpdate(
        'update registered_outlets set is_uploaded=1 where mobile_request_id=?1 ',
        args);
    return true;
  }

  Future<List<Map<String, dynamic>>> getAllAddedItemsOfOrder(
      int orderId) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(orderId);

    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select * from outlet_order_items where order_id=?1", args);
    //print(maps);

    return maps;
  }

  Future<void> deleteUploadedOrder(orderId) async {
    final Database db = await database;
    List args = new List();
    args.add(orderId);
    int isdeleted2 = await db.rawDelete(
        "delete from outlet_order_items where order_id=?1", args);
    int isdeleted =
        await db.rawDelete("delete from outlet_orders where id=?1", args);

    if (isdeleted > 0) {
      //print("Deleted outlet_orders");

      if (isdeleted2 > 0) {
        //print("Deleted outlet_orders_items");
        return true;
      } else {
        //print("not Deleted outlet_orders_items");
        return false;
      }
    } else {
      //print("not Deleted outlet_orders");
      return false;
    }
  }

  Future<void> deleteOrderItem(int orderId, int itemId) async {
    final Database db = await database;
    List args = new List();
    args.add(orderId);
    args.add(itemId);
    await db.rawDelete(
        "delete from outlet_order_items where order_id=?1 and product_id=?2",
        args);
  }

  Future<void> deleteOrderItemBySourceId(int orderId, int sourceId) async {
    final Database db = await database;
    List args = new List();
    args.add(orderId);
    args.add(sourceId);
    print("delete from outlet_order_items where order_id=$orderId and source_id=$sourceId");
    await db.rawDelete(
        "delete from outlet_order_items where order_id=?1 and source_id=?2",
        args);
  }
  Future<List<Map<String, dynamic>>> getUserAgain() async {
    // Get a reference to the database.
    await this.initdb();
    final Database db = await database;

    // Query the table for all The Dogs.

    final List<Map> maps = await db.rawQuery(
        "select user_id,display_name,IsOutletLocationUpdate  from users");

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    //print('list: ');
    //print(maps);
    return maps;
  }

  Future<List<Map<String, dynamic>>> getUser(
      int UserId, String Password) async {
    // Get a reference to the database.
    await this.initdb();
    final Database db = await database;

    // Query the table for all The Dogs.
    List args = new List();
    args.add(UserId);
    args.add(Password);
    final List<Map> maps = await db.rawQuery(
        "select user_id,display_name,designation,distributor_employee_id,password, created_on   from users where user_id=? and password=?",
        args);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    //print('list: ');
    //print(maps);
    return maps;
  }

  Future<void> deleteUsers() async {
    final Database db = await database;
    await db.delete('users');
  }
  Future<void> deletePJP() async {
    final Database db = await database;
    await db.delete('selected_pjp');
  }

  Future<void> insertUser(User user) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    // //print(product);
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<void> insertlocation(User user) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    // //print(product);
    await db.insert(
      'update_location',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPJP(PJP pjp) async {
    final Database db = await database;
    try {
      await db.insert(
        'selected_pjp',
        pjp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      print("ERROR in inserting PJP : "+error.toString());
      //print(error);
    }
  }
  Future<int> isVisitExists(outletId) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(outletId);
    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select * from outlet_orders where is_completed=1 and outlet_id=?1 and date(created_on)= DATE('NOW')",
        args);
    int typeId = 0;
    final List<Map> maps1 = await db.rawQuery(
        "select * from outlet_no_orders where outlet_id=?1 and date(created_on)= DATE('NOW')",
        args);
    final List<Map> maps2 = await db.rawQuery(
        "select * from outlet_mark_close where outlet_id=?1 and date(created_on)= DATE('NOW')",
        args);
    //print(maps1.toString());

    if (maps.isNotEmpty || maps2.isNotEmpty || maps1.isNotEmpty) {
      typeId = 1;
    }


    return typeId;
  }


  /**
   * Returns visit type
   * 0 for not visited
   * 1 for order
   * 2 for no order
   * 3 for outlet closed
  */
  Future<int> getVisitType(String outletId) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(outletId);
    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select * from outlet_orders where is_completed=1 and outlet_id=?1 and date(created_on)= DATE('NOW')",
        args);
    //print(maps.toString());
    int typeId = 0;

    final List<Map> maps1 = await db.rawQuery(
        "select * from outlet_no_orders where outlet_id=?1 and date(created_on)= DATE('NOW')",
        args);
    final List<Map> maps2 = await db.rawQuery(
        "select * from outlet_mark_close where outlet_id=?1 and date(created_on)= DATE('NOW')",
        args);
    //print(maps1.toString());

    if (maps1.isNotEmpty) {
      //print("i am here danish");
      typeId = 2;
    }
    if (maps.isNotEmpty) {
      typeId = 1;
    }

    if (maps2.isNotEmpty) {
      typeId = 3;
    }

    return typeId;
  }
  Future<bool> saveOutletOrderImage(List DocumentPicture) async {
    await this.initdb();
    final Database db = await database;
    int j = 0;
    try {
      for (int i = 0; i < DocumentPicture.length; i++) {
        List args = new List();

        args.add(DocumentPicture[i]['id']);
        args.add(DocumentPicture[i]['documentfile'].toString());
        args.add(DocumentPicture[i]['created_on'].toString());

        j = await db.rawInsert(
            'insert into outlet_orders_images(id  , file , created_on ) values  (?,?,?) ',
            args);
      }
    } catch (error) {
      //print("//print ERROR");
      //print(error);
    }
    if (j > 0) {
      //print("created");
      return true;
    } else {
      //print("not created");
      return false;
    }
  }//
//Created by Irteza
  Future<bool> saveOutletRegistrationImage(List DocumentPicture) async {
    await this.initdb();
    final Database db = await database;
    int j = 0;
    try {
      for (int i = 0; i < DocumentPicture.length; i++) {
        List args = new List();

        args.add(DocumentPicture[i]['id']);
        args.add(DocumentPicture[i]['documentfile'].toString());

        j = await db.rawInsert(
            'insert into outlet_Registration_images(id  , file) values  (?,?) ',
            args);
      }
    } catch (error) {
      //print("//print ERROR");
      //print(error);
    }
    if (j > 0) {
      print("created");
      return true;
    } else {
      print("not created");
      return false;
    }
  }

  Future<bool> saveOutletNOOrderImage(List DocumentPicture) async {
    await this.initdb();
    final Database db = await database;
    int j = 0;
    try {
      for (int i = 0; i < DocumentPicture.length; i++) {
        List args = new List();

        args.add(DocumentPicture[i]['id']);
        args.add(DocumentPicture[i]['file_type_id']);
        args.add(DocumentPicture[i]['documentfile'].toString());

        j = await db.rawInsert(
            'insert into outlet_no_orders_images(id , file_type_id , file) values  (?,?,?) ',
            args);
      }
    } catch (error) {
      //print("//print ERROR");
      //print(error);
    }
    if (j > 0) {
      //print("created");
      return true;
    } else {
      //print("not created");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllOutletImages(int id) async {
    await this.initdb();
    final Database db = await database;
    final List<Map> maps = await db.rawQuery(
        "select *  from outlet_orders_images where is_uploaded=0 and id=" +
            id.toString());

    return maps;
  }//
//Created by Irteza

  Future<List<Map<String, dynamic>>> getNewOutletImages(int id) async {
    await this.initdb();
    print("=============================="+id.toString());
    final Database db = await database;
    final List<Map> maps = await db.rawQuery(
        "select *  from outlet_Registration_images where is_uploaded=0 and id=" +
            id.toString());

    return maps;
  }

  Future<List<Map<String, dynamic>>> getNoOrderImages(int id) async {
    print("ID=======>" + id.toString());
    await this.initdb();
    final Database db = await database;
    final List<Map> maps = await db.rawQuery(
        "select *  from outlet_no_orders_images where is_uploaded=0 and id=" +
            id.toString());

    return maps;
  }
//
  Future markPhotoUploaded(int id) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(id);
    try {
      await db.rawUpdate(
          'update outlet_orders_images set is_uploaded=1  where id=?1 ', args);
    } catch (error) {
      print("markMerchandisingPhotoUploaded  ==>> " + error);
    }

    return true;
  }

  //Created by Irteza
  Future markOutletRegistrationPhotoUploaded(int id) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(id);
    try {
      await db.rawUpdate(
          'update outlet_Registration_images set is_uploaded=1  where id=?1 ', args);
    } catch (error) {
      print("markMerchandisingPhotoUploaded  ==>> " + error);
    }

    return true;
  }

  Future markNoOrderPhotoUploaded(int id , int fileTypeId ) async {
   print("file_type_id"+fileTypeId.toString());
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(id);
    args.add(fileTypeId);
    try {
      await db.rawUpdate(
          'update outlet_no_orders_images set is_uploaded=1  where id=?1 and file_type_id=?2' , args);
    } catch (error) {
      print("markMerchandisingPhotoUploaded  ==>> " + error);
    }

    return true;
  }

  /**
   * set visit type
   * 0 for not visited
   * 1 for order
   * 2 for no order
   * 3 for outlet closed
   */
  Future setVisitType(int outletId, int visitType) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(outletId);
    args.add(visitType);
    await db.rawUpdate(
        'update pre_sell_outlets2 set visit_type=?2 where outlet_id=?1 ', args);
    return true;
  }

  /***************************************************************/
  //FARHAN WORK Starts
  /***************************************************************/
  Future<void> deleteAllOutletProductsAlternativePrices() async {
    final Database db = await database;
    await db.delete('outlet_product_alternative_prices');
  }

  Future<void> insertOutletProductsAlternativePrices(
      OutletProductsAlternativePrices ProductsPrices) async {
    // Get a reference to the database.
    final Database db = await database;
    try {
      await db.insert(
        'outlet_product_alternative_prices',
        ProductsPrices.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      //print("ERROR outlet_product_alternative_prices : "+error);
      //print(error);
    }
  }

  Future<void> deleteAllOutletAreas() async {
    final Database db = await database;
    await db.delete('outlet_areas');
  }

  Future<void> insertOutletAreas(OutletAreas outletAreas) async {
    final Database db = await database;
    try {
      await db.insert(
        'outlet_areas',
        outletAreas.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      //print("ERROR insertOutletAreas : "+error);
      //print(error);
    }
  }

  Future<void> deleteAllOutletSubAreas() async {
    final Database db = await database;
    await db.delete('outlet_sub_areas');
  }

  Future<void> insertOutletSubAreas(OutletSubAreas outletSubAreas) async {
    final Database db = await database;
    try {
      await db.insert(
        'outlet_sub_areas',
        outletSubAreas.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      //print("ERROR insertOutletSubAreas : "+error);
      //print(error);
    }
  }

  Future<void> deleteAllPCISubAreas() async {
    final Database db = await database;
    await db.delete('pci_sub_channel');
  }

  Future<void> insertPCISubAreas(PCISubAreas pciSubAreas) async {
    final Database db = await database;
    try {
      await db.insert(
        'pci_sub_channel',
        pciSubAreas.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      //print("ERROR insertPCISubAreas : "+error);
      //print(error);
    }
  }

  Future<List<Map<String, dynamic>>> getOutletProductsAlternativePrices(
      int productId) async {
    // Get a reference to the database.
    await this.initdb();
    final Database db = await database;

    // Query the table for all The Dogs.
    List args = new List();
    args.add(productId);
    final List<Map> maps = await db.rawQuery(
        "select *  from outlet_product_alternative_prices where product_id=?1 limit 1",
        args);

    return maps;
  }

  Future registerOutlet(List formFields) async {
    await this.initdb();
    final Database db = await database;

    for (int i = 0; i < formFields.length; i++) {
      print("saved "+ i.toString());
      List args = new List();
      args.add(globals.OutletIdforupdate.toString());
      args.add(formFields[i]['outlet_name'].toString());
      args.add(formFields[i]['mobile_request_id'].toString());

      args.add(formFields[i]['pic_channel_id']);
      args.add(formFields[i]['area_label'].toString());
      args.add(formFields[i]['sub_area_label'].toString());
      args.add(formFields[i]['address'].toString());
      args.add(formFields[i]['owner_name'].toString());
      args.add(formFields[i]['owner_cnic'].toString());
      args.add(formFields[i]['owner_mobile_no'].toString());
      args.add(formFields[i]['purchaser_name'].toString());
      args.add(formFields[i]['purchaser_mobile_no'].toString());
      args.add(formFields[i]['is_owner_purchaser'].toString());
      args.add(formFields[i]['lat']);
      args.add(formFields[i]['lng']);
      args.add(formFields[i]['accuracy']);

      args.add(formFields[i]['created_by']);
      args.add(formFields[i]['is_uploaded']);
      args.add(formFields[i]['is_new']);
      args.add(formFields[i]['outletchannel']);

      //"CREATE TABLE (outlet_name TEXT,mobile_request_id TEXT,mobile_timestamp TEXT, channel_id INTEGER,sub_area_id INTEGER,address TEXT, owner_name TEXT,owner_cnic TEXT, owner_mobile_no TEXT,purchaser_name TEXT,purchaser_mobile_no TEXT, is_owner_purchaser INTGER, lat REAL, lng REAL, accuracy INTEGER, created_on TEXT,created_by INTEGER)"

      await db.rawInsert(
          'insert into registered_outlets (id_for_update,outlet_name ,mobile_request_id ,mobile_timestamp,channel_id ,area_label,sub_area_label ,address,owner_name,owner_cnic,owner_mobile_no,purchaser_name,purchaser_mobile_no,is_owner_purchaser,lat,lng,accuracy,created_on,created_by,is_uploaded,is_new,outletchannel) values  (?,?,?,DATETIME("now","5 hours"),?,?,?,?,?,?,?,?,?,?,?,?,?,DATETIME("now","5 hours"),?,?,?,?) ',
          args);
    }

    return true;
  }

  Future<List<Map<String, dynamic>>> getAllRegisteredOutletsByIsUploaded(
      int isUploaded, int isNew) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(isUploaded);
    args.add(isNew);

    final List<Map> maps = await db.rawQuery(
        "select * from registered_outlets where  is_uploaded=?1 AND is_new=?2", args);

    return maps;
  }

  Future<List<Map<String, dynamic>>> getPCIChannels() async {
    await this.initdb();
    final Database db = await database;

    final List<Map> maps = await db.rawQuery("select *  from pci_sub_channel");

    return maps;
  }
  Future<List<Map<String, dynamic>>> getOutletChannel() async {
    await this.initdb();
    final Database db = await database;

    final List<Map> maps = await db.rawQuery("select *  from Outlets_channel");

    return maps;
  }

  Future<List<Map<String, dynamic>>> getOutletAreas() async {
    await this.initdb();
    final Database db = await database;

    final List<Map> maps = await db.rawQuery("select *  from outlet_areas ");

    //print('getOutletAreas: ');

    //print(maps);
    return maps;
  }

  Future<List> getChannelSuggestions(String query) async {
    await initdb();
    final Database db = await database;
    // await Future.delayed(Duration(seconds: 1));

    List args = new List();
    args.add(query);
    //print("QUERY"+query);

    final List maps = await db.rawQuery(
        "select id,label  from pci_sub_channel where label like ?1", args);

    //print('pci_sub_channel: ');

    //print(maps);
    return maps;

    /*
    return List.generate(3, (index) {
      return {'name': query + index.toString(), 'price': Random().nextInt(100)};
    });
*/
  }
  Future<List> getChannel(String query) async {
    await initdb();
    final Database db = await database;
    // await Future.delayed(Duration(seconds: 1));

    List args = new List();
    args.add(query);
    //print("QUERY"+query);

    final List maps = await db.rawQuery(
        "select id,label  from Outlets_channel where label like ?1", args);

    //print('pci_sub_channel: ');

    //print(maps);
    return maps;

    /*
    return List.generate(3, (index) {
      return {'name': query + index.toString(), 'price': Random().nextInt(100)};
    });
*/
  }
  Future<List> getAreaSuggestions(String query) async {
    await initdb();
    final Database db = await database;
    //await Future.delayed(Duration(seconds: 1));

    List args = new List();
    args.add(query);
    //print("QUERY"+query);

    final List maps = await db.rawQuery(
        "select id,label  from outlet_areas where label like ?1", args);

    //print('getOutletAreas: ');

    //print(maps);
    return maps;
/*
    return List.generate(3, (index) {
      return {'name': query + index.toString(), 'price': Random().nextInt(100)};
    });
*/
  }

  Future<List> getSubAreaSuggestions(String query, int areaId) async {
    await initdb();
    final Database db = await database;
    //await Future.delayed(Duration(seconds: 1));

    List maps = null;
    if (query != "") {
      List args = new List();
      args.add(areaId);
      args.add(query);
      //print("QUERY"+query);
      maps = await db.rawQuery(
          "select id,label from outlet_sub_areas where area_id=?1 and label like ?2",
          args);
    } else {
      List args = new List();
      args.add(areaId);
      //print("QUERY"+query);
      maps = await db.rawQuery(
          "select id,label from outlet_sub_areas where id area_id=?1 ", args);
    }

    //print('outlet_sub_areas: ');

    //print(maps);
    return maps;
  }

/***************************************************************/
//FARHAN WORK ENDS
/***************************************************************/

  Future<List<Map<String, dynamic>>> getAllMarkedAttendances(int isUploaded) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(isUploaded);
    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select * from attendance where is_uploaded=?1",
        args);

    return maps;
  }

  Future<List<Map<String, dynamic>>> getAllMarkedUploadedAttendances(int isPhotoUploaded) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(isPhotoUploaded);
    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select * from attendance where is_uploaded=1 and is_photo_uploaded=?1",
        args);

    return maps;
  }

  Future markAttendance(mobileRequestId,imagePath,attendanceTypeId,lat,lng,accuracy,userId,isUploaded,uuid,isPhotoUploaded) async {
    await this.initdb();
    final Database db = await database;

    try {

      await db.rawInsert(
        'insert into attendance (mobile_request_id ,mobile_timestamp,attendance_type_id,lat,lng,accuracy,is_uploaded,uuid,image_path,user_id,is_photo_uploaded) values  (?,DATETIME("now","5 hours"),?,?,?,?,?,?,?,?,?) ',
          [mobileRequestId, attendanceTypeId, lat, lng, accuracy, isUploaded,uuid,imagePath,userId,isPhotoUploaded]);

      } catch (error) {
      print(error);
  }

    return true;
  }




  Future UpdateOutletLocation(int outletId, String lat, String lng, String accuracy) async {
    print("markAttendanceUploaded id" + outletId.toString());
    await this.initdb();
    final Database db = await database;

    try {
      await db.rawUpdate(
          'UPDATE pre_sell_outlets2 SET lat = ?, lng = ?, accuracy = ? WHERE outlet_id = ?',
          [lat, lng, accuracy, outletId]
      );
    } catch (error) {
      print("markAttendanceUploaded ==>> " + error.toString());
    }

    return true;
  }

  Future markAttendanceUploaded(int id) async {
    print("markAttendanceUploaded id"+id.toString());
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(id);

    try{
      await db.rawUpdate(
          'update attendance set is_uploaded=1 where mobile_request_id=?1 ', args);

    }catch(error){print("markAttendanceUploaded ==>> "+error);}

    return true;
  }

  Future markAttendanceUploadedPhoto(int id) async {
    print("markAttendanceUploaded id  ==>> "+id.toString());
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(id);
    try{
      await db.rawUpdate(
          'update attendance set is_photo_uploaded=1 where mobile_request_id=?1 and is_uploaded=1', args);

    }catch(error){print("markAttendanceUploadedPhoto ==>> "+error);}

    return true;
  }



  Future insertMerchandising(mobileRequestId,outletId,lat,lng ,accuracy,isCompleted,uuid,imagesList,isPhotoUploaded,userId) async {
    await this.initdb();
    final Database db = await database;
    try {
      for(int i=0;i<imagesList.length;i++){
         await db.rawInsert(
          'insert into merchandising (mobile_request_id ,outlet_id ,user_id ,mobile_timestamp ,lat , lng , accuracy ,is_completed,uuid,image,type_id,is_photo_uploaded) values  (?,?,?,DATETIME("now","5 hours"),?,?,?,?,?,?,?,?)',
                                       [mobileRequestId,outletId,userId,lat , lng , accuracy,isCompleted,uuid,imagesList[i]["image"],imagesList[i]["typeId"],isPhotoUploaded]);
      }
    } catch (error) {
      print(error);
    }

    return true;
  }

  Future<List<Map<String, dynamic>>> getAllMerchandising(int isPhotoUploaded) async {
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(isPhotoUploaded);
    // Query the table for all The Dogs.
    final List<Map> maps = await db.rawQuery(
        "select * from merchandising where is_photo_uploaded=?1", args);

    return maps;
  }



  Future markMerchandisingPhotoUploaded(int id,int typeId) async {
    print("markMerchandisingPhotoUploaded id  ==>> "+id.toString());
    await this.initdb();
    final Database db = await database;
    List args = new List();
    args.add(id);
    args.add(typeId);
    try{
      await db.rawUpdate(
          'update merchandising set is_photo_uploaded=1  where mobile_request_id=?1 and type_id=?2', args);

    }catch(error){
      print("markMerchandisingPhotoUploaded  ==>> "+error);
    }

    return true;
  }

}
