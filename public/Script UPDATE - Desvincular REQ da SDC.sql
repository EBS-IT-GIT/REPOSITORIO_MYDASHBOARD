UPDATE apps.po_distributions_all
   SET req_distribution_id = NULL
 WHERE req_distribution_id IN (8923299
                              ,8923302
                              ,8923304
                              ,8923307
                              ,8923308
                              ,8923309
                              ,8923310
                              ,8923311
                              ,8923312
                              ,8923314
                              ,8923320);

UPDATE apps.po_distributions_archive_all
   SET req_distribution_id = NULL
 WHERE req_distribution_id IN (8923299
                              ,8923302
                              ,8923304
                              ,8923307
                              ,8923308
                              ,8923309
                              ,8923310
                              ,8923311
                              ,8923312
                              ,8923314
                              ,8923320);
  
UPDATE apps.po_line_locations_all
   SET from_line_id = NULL
 WHERE from_line_id IN (11064341
                       ,11064343
                       ,11064344
                       ,11064346
                       ,11064349
                       ,11064350
                       ,11064351
                       ,11064352
                       ,11064353
                       ,11064354
                       ,11064356
                       ,11064362);
                       
COMMIT;
