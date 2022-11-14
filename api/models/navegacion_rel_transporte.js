/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('navegacion_rel_transporte', {
		fk_navegacion_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'navegacion',
				key: 'id_navegacion'
			}
		},
		fk_transporte_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'transporte',
				key: 'id_transporte'
			}
		},
		tipo_navegacion: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'navegacion_rel_transporte',
		timestamps: false
	});
};
