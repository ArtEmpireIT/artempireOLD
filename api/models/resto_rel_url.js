/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('resto_rel_url', {
    fk_resto_variable: {
      type: DataTypes.STRING,
      allowNull: false,
      primaryKey: true,
      references: {
        model: 'resto',
        key: 'variable'
      }
    },
    fk_url_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'url',
        key: 'id_url'
      }
    }
  }, {
    tableName: 'resto_rel_url',
    timestamps: false
  });
};
