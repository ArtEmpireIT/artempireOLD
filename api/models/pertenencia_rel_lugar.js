/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('pertenencia_rel_lugar', {
		fk_pertenencia_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'pertenencia',
				key: 'id_pertenencia'
			}
		},
		tipo_lugar: {
			type: DataTypes.STRING,
			allowNull: true
		},
		precision_pert_lugar: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_lugar_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'lugar',
				key: 'id_lugar'
			}
		}
	}, {
		tableName: 'pertenencia_rel_lugar',
		timestamps: false
	});
};
