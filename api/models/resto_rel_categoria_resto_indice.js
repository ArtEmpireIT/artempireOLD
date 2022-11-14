/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('resto_rel_categoria_resto_indice', {
		fk_resto_variable: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'resto',
				key: 'variable'
			}
		},
		fk_categoria_resto_indice_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'categoria_resto_indice',
				key: 'id_categoria_resto_indice'
			}
		}
	}, {
		tableName: 'resto_rel_categoria_resto_indice',
		timestamps: false
	});
};
