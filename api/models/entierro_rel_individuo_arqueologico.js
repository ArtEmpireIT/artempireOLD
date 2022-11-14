/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('entierro_rel_individuo_arqueologico', {
    fk_entierro_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      references: {
        model: 'entierro',
        key: 'id_entierro'
      }
    },
    fk_individuo_arqueologico_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'individuo_arqueologico',
        key: 'id_individuo_arqueologico'
      }
    }
  }, {
    tableName: 'entierro_rel_individuo_arqueologico',
    timestamps: false
  });
};
