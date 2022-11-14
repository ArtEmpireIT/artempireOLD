/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('categoria_resto_rel_anomalia', {
		fk_categoria_resto: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'categoria_resto',
				key: 'nombre'
			}
		},
		fk_anomalia_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'anomalia',
				key: 'id_anomalia'
			}
		},
		obligatorio: {
			type: DataTypes.BOOLEAN,
			allowNull: false
		}
	}, {
		tableName: 'categoria_resto_rel_anomalia',
		timestamps: false
	});
};
